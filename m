From: Ivan Dichev <idichev@obs.bg>
Subject: Re: Slow OOM in netif_RX function
Date: Fri, 01 Feb 2008 17:38:42 +0200
Message-ID: <47A33D02.8050503@obs.bg>
References: <4798CAA9.1080005@obs.bg> <4798E32E.6080003@cosmosbay.com> <20080124211810.3E24A46E9A@smtp.obs.bg> <p73tzl282ij.fsf@bingen.suse.de> <20080125141204.GA25510@ghostprotocols.net> <47A315DC.3070101@obs.bg> <47A31BBA.8040307@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from obs.bg ([213.91.169.3]:33473 "EHLO smtp.obs.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753892AbYBAPio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 10:38:44 -0500
In-Reply-To: <47A31BBA.8040307@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I understand you dont want to tell us exact firewall rules you have.
>
> Maybe you could post at least following infos :
>
> # cat /proc/slabinfo
> # lsmod
>
I have changed slab with slub.

firewall #   cat /sys/slab/kmalloc-2048/alloc_calls
      1 add_sect_attrs+0x57/0x120 age=20565254 pid=1115
      1 __vmalloc_area_node+0x5d/0xf3 age=586962 pid=31548
      6 journal_init_revoke+0xe0/0x241 age=20562046/20563010/20566655
pid=1-1510
      6 journal_init_revoke+0x1c7/0x241 age=20562046/20563010/20566655
pid=1-1510
      6 journal_init_inode+0x7d/0x123 age=20562046/20563010/20566655
pid=1-1510
      1 tty_write+0xe8/0x1bc age=685813 pid=21217
      1 input_allocate_device+0x10/0x6c age=20566814 pid=38
      2 reqsk_queue_alloc+0x58/0xa8 age=5679409/8932742/12186076
pid=1135-2500
      5 alloc_netdev_mq+0x3c/0x9a age=20555675/20561345/20565141
pid=1233-3041
      1 neigh_hash_alloc+0x14/0x2c age=20527064 pid=0
     11 neigh_sysctl_register+0x24/0x1fd age=20555673/20560511/20567588
pid=1-3041
      6 qdisc_alloc+0x1b/0x70 age=585308/585373/585539 pid=31629-31818
     26 qdisc_get_rtab+0x5e/0xa2 age=585498/585519/585535 pid=31630-31664
     11 devinet_sysctl_register+0x21/0xd7 age=20555673/20560511/20567588
pid=1-3041
      1 netlink_proto_init+0x2a/0x123 age=20567604 pid=1
   3106 boomerang_rx+0x30d/0x40d [3c59x] age=1/9966140/20553543 pid=0-22895
      3 bm_init+0x28/0xa3 [ts_bm] age=586918/586918/586918 pid=31548

firewall #  cat /sys/slab/kmalloc-2048/free_calls
    109 <not-available> age=20515711 pid=0
      1 rcu_do_batch+0x1a/0x71 age=608627 pid=31627
     19 kobject_uevent_env+0x3c5/0x3da age=20578755/20585359/20590686
pid=1-3041
   3055 kfree_skbmem+0x8/0x68 age=3/9973654/20579063 pid=0-31818
      1 pskb_expand_head+0xe3/0x13d age=15946314 pid=695
      1 huft_build+0x498/0x4a2 age=20590653 pid=1
      3 htb_destroy_class+0x5e/0x12e [sch_htb] age=608630/608630/608630
pid=31625
      6 htb_destroy_class+0x69/0x12e [sch_htb] age=608630/608630/608630
pid=31625
fire-sp # lsmod
Module                  Size  Used by
xt_string               2272  3
ipt_ULOG                8004  5
ipt_recent              9360  40
softdog                 5792  0
act_mirred              5060  4
cls_u32                 7972  4
sch_sfq                 5760  56
cls_fw                  5408  54
sch_htb                16192  6
ifb                     5156  0
aes                    28512  0
des                    15456  0
md5                     3936  0
sha256                  9248  0
ipsec                 312176  2
nf_nat_tftp             1792  0
nf_conntrack_tftp       5144  1 nf_nat_tftp
nf_nat_pptp             3712  0
nf_conntrack_pptp       6688  1 nf_nat_pptp
nf_conntrack_proto_gre     4992  1 nf_conntrack_pptp
nf_nat_proto_gre        2724  1 nf_nat_pptp
nf_nat_ftp              3236  0
nf_conntrack_ftp        8680  1 nf_nat_ftp
ipt_tos                 1536  492
xt_mark                 1760  12
xt_DSCP                 2336  13
ipt_NETMAP              1888  6
xt_TCPMSS               4064  4
xt_length               1856  3
ts_bm                   2304  3
xt_mac                  1792  28
ipt_REJECT              4416  74
xt_limit                2496  153
xt_state                2368  2948
iptable_nat             7172  1
nf_nat                 18412  6
nf_nat_tftp,nf_nat_pptp,nf_nat_proto_gre,nf_nat_ftp,ipt_NETMAP,iptable_nat
nf_conntrack_ipv4      16744  2950 iptable_nat
nf_conntrack           57412  11
nf_nat_tftp,nf_conntrack_tftp,nf_nat_pptp,nf_conntrack_pptp,nf_conntrack_proto_gre,nf_nat_ftp,nf_conntrack_ftp,xt_state,iptable_nat,nf_nat,nf_conntrack_ipv4
nfnetlink               5784  3 nf_nat,nf_conntrack_ipv4,nf_conntrack
xt_MARK                 2176  28
iptable_mangle          2720  1
xt_multiport            3232  2325
iptable_filter          2852  1
ip_tables              12824  3 iptable_nat,iptable_mangle,iptable_filter
binfmt_misc            10792  1
dm_mirror              20608  0
dm_mod                 53280  1 dm_mirror
i2c_viapro              8252  0
i2c_core               23376  1 i2c_viapro
3c59x                  41132  0
mii                     5280  1 3c59x
floppy                 53892  0
pata_via               11684  0
libata                110188  1 pata_via
scsi_mod              137996  1 libata
raid1                  20448  7
firewall#
