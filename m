From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Sun, 12 Sep 2004 13:03:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040912110320.GA21197@electric-eye.fr.zoreil.com>
References: <E1C4wYe-0005qT-00@gondolin.me.apana.org.au> <20040908072408.GI27886@wotan.suse.de> <1094629677.1089.155.camel@jzny.localdomain> <20040908134713.1bcd46d3.davem@davemloft.net> <1094823215.1121.129.camel@jzny.localdomain> <20040911142116.GL4431@wotan.suse.de> <1094933731.2343.109.camel@jzny.localdomain> <20040911174535.2acbb957.davem@davemloft.net> <20040912100114.GB11484@havoc.gtf.org> <20040912102529.GA27096@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, hadi@cyberus.ca,
        herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040912102529.GA27096@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen <ak@suse.de> :
[...]
> I wasn't aware of Documentation/netdevices.txt, but I agree it 
> would be a good idea to update it. Patch for that attached.
> DaveM, please apply.

I have modified your patch so as to include a bit from a message
of Jamal on netdev the 05/07/2004.

diff -u linux-2.6.8-work/Documentation/networking/netdevices.txt-o linux-2.6.8-work/Documentation/networking/netdevices.txt
--- linux-2.6.8-work/Documentation/networking/netdevices.txt-o	2004-03-21 21:12:11.000000000 +0100
+++ linux-2.6.8-work/Documentation/networking/netdevices.txt	2004-09-12 12:24:02.000000000 +0200
@@ -43,8 +43,21 @@
 
 dev->hard_start_xmit:
 	Synchronization: dev->xmit_lock spinlock.
+	When the driver sets NETIF_F_LLTX in dev->features this will be
+	called without holding xmit_lock. In this case the driver 
+	has to lock by itself when needed. It is recommended to use a try lock
+	for this and return -1 when the spin lock fails. 
+	The locking there should also properly protect against 
+	set_multicast_list
 	Context: BHs disabled
 	Notes: netif_queue_stopped() is guaranteed false
+	Return codes: 
+	o 0 everything ok. 
+	o 1 Cannot transmit packet, try later 
+	  Usually a bug, means queue start/stop flow control is broken in
+	  the driver. Note: the driver must NOT put the skb in its DMA ring.
+	o -1 Locking failed, please retry quickly. Only valid when 
+	  NETIF_F_LLTX is set.
 
 dev->tx_timeout:
 	Synchronization: dev->xmit_lock spinlock.
