From: "Thiago Lacerda" <thiagotbl@gmail.com>
Subject: Problems with dev_add_pack()
Date: Sun, 31 Aug 2008 02:59:09 -0300
Message-ID: <3fedcc3b0808302259p67e6d70bke1ff13f0902c2b1e@mail.gmail.com>
References: <3fedcc3b0808302250n4054eae7y8151b725a3011099@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:25751 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbYHaF7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2008 01:59:10 -0400
Received: by yw-out-2324.google.com with SMTP id 9so173345ywe.1
        for <netdev@vger.kernel.org>; Sat, 30 Aug 2008 22:59:09 -0700 (PDT)
In-Reply-To: <3fedcc3b0808302250n4054eae7y8151b725a3011099@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

I've registered a protocol handler with dev_add_pack, but seems that
it isn't capturing all the packets.
Every time that I receive an IP packet I increment a variable.
At the same time I am running my module I have a tcpdump instance
running (also capturing IP packets) and, when I stop both captures,
the counters (from tcpdump and from my module) differs from each other
(my module always capture less packets).

Does anyone know why that is happening?

Here is my code:

int my_handler (struct sk_buff *, struct net_device *, struct
packet_type *, struct net_device *);

struct packet_type pktype = {
        .type = __constant_htons(ETH_P_ALL),
        .func = my_handler,
};
unsigned int numberOfPackets;

static int init_mod(void) {
    printk(KERN_ALERT"Initializing Module\n");
    struct net_device* d = dev_get_by_name(&init_net, "eth1");
    if(d != NULL) {
        pktype.dev = d;
        dev_add_pack(&pktype);
    }
    numberOfPackets = 0;
    return 0;
}

static void exit_mod(void) {
    dev_remove_pack(&pktype);
    printk(KERN_ALERT"Exiting Module\n");
    printk(KERN_ALERT"Number of Packets: %u\n", numberOfPackets);
}

int my_handler (struct sk_buff * buff, struct net_device * dev, struct
packet_type * pt, struct net_device * dev2) {
    struct sk_buff* my_sock;
    my_sock = buff;
    if(!my_sock) {
        printk(KERN_ALERT"SK_BUFF NULL!!!!\n");
    }
    else {
        struct ethhdr* ethernet = eth_hdr(my_sock);
        if(ethernet->h_proto == __constant_htons(ETH_P_IP)) {
            numberOfPackets++;
        }
    }
    return 0;
}

Thanks in advance


--
Thiago de Barros Lacerda
Computer Science Undergraduate Student - CIn/UFPE - 2004.2
Researcher/Software Developer - GPRT - Networking and
Telecommunications Research Group
