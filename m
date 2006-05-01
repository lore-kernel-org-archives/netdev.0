From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 2/3] Eleminate HZ from NET/ROM kernel interfaces
Date: Tue, 2 May 2006 00:52:35 +0100
Message-ID: <20060501235235.GA18868@linux-mips.org>
References: <20060429141613.GA2811@linux-mips.org> <44551148.5010503@ccr.jussieu.fr> <20060430.172136.99531184.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pidoux@ccr.jussieu.fr, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060430.172136.99531184.davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 30, 2006 at 05:21:36PM -0700, David S. Miller wrote:

> > With such extensive patches for netrom and rose modules that will go 
> > into a future 2.6.x kernel, I think it would be justified to update the 
> > following banners in af_rose.c and af_netrom.c respectively for they 
> > appear during boot :
> 
> It might be worthwhile to remove the messages altogether.
> 
> IPV4 and the core networking used to output similar initialization
> log messages and it really doesn't really add anything but pollute
> the already voluminous kernel log.
> 
> So I say we just remove it.

Agreed, patch to remove the messages is below.

  Ralf

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 net/netrom/af_netrom.c |    3 ---
 net/rose/af_rose.c     |    3 ---
 2 files changed, 6 deletions(-)

Index: linux-net.git/net/netrom/af_netrom.c
===================================================================
--- linux-net.git.orig/net/netrom/af_netrom.c	2006-04-30 10:28:32.000000000 +0100
+++ linux-net.git/net/netrom/af_netrom.c	2006-05-02 00:48:59.000000000 +0100
@@ -1370,8 +1370,6 @@ static struct notifier_block nr_dev_noti
 
 static struct net_device **dev_nr;
 
-static char banner[] __initdata = KERN_INFO "G4KLX NET/ROM for Linux. Version 0.7 for AX25.037 Linux 2.4\n";
-
 static int __init nr_proto_init(void)
 {
 	int i;
@@ -1419,7 +1417,6 @@ static int __init nr_proto_init(void)
 	}
 		
 	register_netdevice_notifier(&nr_dev_notifier);
-	printk(banner);
 
 	ax25_protocol_register(AX25_P_NETROM, nr_route_frame);
 	ax25_linkfail_register(nr_link_failed);
Index: linux-net.git/net/rose/af_rose.c
===================================================================
--- linux-net.git.orig/net/rose/af_rose.c	2006-04-30 13:29:58.000000000 +0100
+++ linux-net.git/net/rose/af_rose.c	2006-05-02 00:48:28.000000000 +0100
@@ -1469,8 +1469,6 @@ static struct notifier_block rose_dev_no
 
 static struct net_device **dev_rose;
 
-static const char banner[] = KERN_INFO "F6FBB/G4KLX ROSE for Linux. Version 0.62 for AX25.037 Linux 2.4\n";
-
 static int __init rose_proto_init(void)
 {
 	int i;
@@ -1519,7 +1517,6 @@ static int __init rose_proto_init(void)
 
 	sock_register(&rose_family_ops);
 	register_netdevice_notifier(&rose_dev_notifier);
-	printk(banner);
 
 	ax25_protocol_register(AX25_P_ROSE, rose_route_frame);
 	ax25_linkfail_register(rose_link_failed);
