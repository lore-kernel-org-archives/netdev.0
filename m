From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [RFC] networking structure holes
Date: Tue, 31 Oct 2006 17:34:32 -0300
Message-ID: <20061031203430.GF5319@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:3758 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1423611AbWJaUey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 15:34:54 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

	I've been working on some DWARF2 utilities and one of them,
pahole (Poke-a-Hole) can be used to find holes due to alignment rules
in structs, the full output of:

[acme@newtoy net-2.6]$ pahole net/ipv4/tcp.o

	is available at:

http://oops.merseine.nu:81/acme/net.ipv4.tcp.o.pahole

	Just to show what we can find with this tool here is the layout
of struct net_device, that barring any cacheline locality optimization
has 4 bytes to harvest, David, do you think reordering those fields to
get 4 byts back is ok?

[acme@newtoy net-2.6]$ pahole net/ipv4/tcp.o net_device

/* /pub/scm/linux/kernel/git/acme/net-2.6/include/linux/skbuff.h:87 */
struct net_device {
        char                       name[16];             /*     0    16 */
        struct hlist_node          name_hlist;           /*    16     8 */
        long unsigned int          mem_end;              /*    24     4 */
        long unsigned int          mem_start;            /*    28     4 */
        long unsigned int          base_addr;            /*    32     4 */
        unsigned int               irq;                  /*    36     4 */
        unsigned char              if_port;              /*    40     1 */
        unsigned char              dma;                  /*    41     1 */

        /* XXX 2 bytes hole, try to pack */

        long unsigned int          state;                /*    44     4 */
        struct net_device *        next;                 /*    48     4 */
        int                        (*init)();            /*    52     4 */
        long unsigned int          features;             /*    56     4 */
        struct net_device *        next_sched;           /*    60     4 */
        int                        ifindex;              /*    64     4 */
        int                        iflink;               /*    68     4 */
        struct net_device_stats *  (*get_stats)();       /*    72     4 */
        const struct iw_handler_def  * wireless_handlers;    /*    76     4 */
        struct iw_public_data *    wireless_data;        /*    80     4 */
        const struct ethtool_ops  * ethtool_ops;          /*    84     4 */
        unsigned int               flags;                /*    88     4 */
        short unsigned int         gflags;               /*    92     2 */
        short unsigned int         priv_flags;           /*    94     2 */
        short unsigned int         padded;               /*    96     2 */
        unsigned char              operstate;            /*    98     1 */
        unsigned char              link_mode;            /*    99     1 */
        unsigned int               mtu;                  /*   100     4 */
        short unsigned int         type;                 /*   104     2 */
        short unsigned int         hard_header_len;      /*   106     2 */
        struct net_device *        master;               /*   108     4 */
        unsigned char              perm_addr[32];        /*   112    32 */
        unsigned char              addr_len;             /*   144     1 */

        /* XXX 1 bytes hole, try to pack */

        short unsigned int         dev_id;               /*   146     2 */
        struct dev_mc_list *       mc_list;              /*   148     4 */
        int                        mc_count;             /*   152     4 */
        int                        promiscuity;          /*   156     4 */
        int                        allmulti;             /*   160     4 */
        void *                     atalk_ptr;            /*   164     4 */
        void *                     ip_ptr;               /*   168     4 */
        void *                     dn_ptr;               /*   172     4 */
        void *                     ip6_ptr;              /*   176     4 */
        void *                     ec_ptr;               /*   180     4 */
        void *                     ax25_ptr;             /*   184     4 */
        struct list_head           poll_list;            /*   188     8 */
        int                        (*poll)();            /*   196     4 */
        int                        quota;                /*   200     4 */
        int                        weight;               /*   204     4 */
        long unsigned int          last_rx;              /*   208     4 */
        unsigned char              dev_addr[32];         /*   212    32 */
        unsigned char              broadcast[32];        /*   244    32 */
        spinlock_t                 queue_lock;           /*   276     0 */
        struct Qdisc *             qdisc;                /*   276     4 */
        struct Qdisc *             qdisc_sleeping;       /*   280     4 */
        struct list_head           qdisc_list;           /*   284     8 */
        long unsigned int          tx_queue_len;         /*   292     4 */
        struct sk_buff *           gso_skb;              /*   296     4 */
        spinlock_t                 ingress_lock;         /*   300     0 */
        struct Qdisc *             qdisc_ingress;        /*   300     4 */
        spinlock_t                 _xmit_lock;           /*   304     0 */
        int                        xmit_lock_owner;      /*   304     4 */
        void *                     priv;                 /*   308     4 */
        int                        (*hard_start_xmit)(); /*   312     4 */
        long unsigned int          trans_start;          /*   316     4 */
        int                        watchdog_timeo;       /*   320     4 */
        struct timer_list          watchdog_timer;       /*   324    24 */
        atomic_t                   refcnt;               /*   348     4 */
        struct list_head           todo_list;            /*   352     8 */
        struct hlist_node          index_hlist;          /*   360     8 */
        enum                       reg_state;            /*   368     4 */
        void                       (*uninit)();          /*   372     4 */
        void                       (*destructor)();      /*   376     4 */
        int                        (*open)();            /*   380     4 */
        int                        (*stop)();            /*   384     4 */
        int                        (*hard_header)();     /*   388     4 */
        int                        (*rebuild_header)();  /*   392     4 */
        void                       (*set_multicast_list)(); /*   396     4 */
        int                        (*set_mac_address)(); /*   400     4 */
        int                        (*do_ioctl)();        /*   404     4 */
        int                        (*set_config)();      /*   408     4 */
        int                        (*hard_header_cache)(); /*   412     4 */
        void                       (*header_cache_update)(); /*   416     4 */
        int                        (*change_mtu)();      /*   420     4 */
        void                       (*tx_timeout)();      /*   424     4 */
        void                       (*vlan_rx_register)(); /*   428     4 */
        void                       (*vlan_rx_add_vid)(); /*   432     4 */
        void                       (*vlan_rx_kill_vid)(); /*   436     4 */
        int                        (*hard_header_parse)(); /*   440     4 */
        int                        (*neigh_setup)();     /*   444     4 */
        struct net_bridge_port *   br_port;              /*   448     4 */
        struct class_device        class_dev;            /*   452   144 */
        struct attribute_group *   sysfs_groups[3];      /*   596    12 */
}; /* size: 608, sum members: 605, holes: 2, sum holes: 3 */

	The git repo for pahole & the other dwarves is at:

git://git.kernel.org/pub/scm/linux/kernel/git/acme/pahole.git

	For those wanting to just look at the cset comments (best
documentation available so far ;)):

http://www.kernel.org/git/?p=linux/kernel/git/acme/pahole.git;a=summary

Best Regards,

- Arnaldo
