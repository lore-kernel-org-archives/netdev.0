From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] ipv4/arp.c:arp_process(): remove bogus #ifdef mess
Date: Sun, 25 Nov 2007 17:30:03 +0100
Message-ID: <20071125163003.GC21947@stusta.de>
References: <200711071434.52607.david-b@pacbell.net> <20071107225232.GB26163@stusta.de> <20071108033010.GF26163@stusta.de> <20071119.212639.217993660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: david-b@pacbell.net, randy.dunlap@oracle.com,
	toralf.foerster@gmx.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756558AbXKYQac@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071119.212639.217993660.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 19, 2007 at 09:26:39PM -0800, David Miller wrote:
> From: Adrian Bunk <bunk@kernel.org>
> Date: Thu, 8 Nov 2007 04:30:10 +0100
> 
> > @davem:
> > 
> > Please look at net/ipv4/arp.c:arp_process()
> > 
> > Am I right that CONFIG_NET_ETHERNET=n and CONFIG_NETDEV_1000=y or 
> > CONFIG_NETDEV_10000=y will not be handled correctly there?
> > 
> > And the best solution is to nuke all #ifdef's in this function and make 
> > the code unconditionally available?
> 
> I think removing those specific ifdefs in arp_process()
> is the best option, yes.

Patch below.

cu
Adrian


<--  snip  -->


The #ifdef's in arp_process() were not only a mess, they were also wrong 
in the CONFIG_NET_ETHERNET=n and (CONFIG_NETDEV_1000=y or 
CONFIG_NETDEV_10000=y) cases.

Since they are not required this patch removes them.

Also removed are some #ifdef's around #include's that caused compile 
errors after this change.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 net/ipv4/arp.c |   19 -------------------
 1 file changed, 19 deletions(-)

759b820456b1400b2a6b061eca9667bf7a6f053d 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 36d6798..0c5d549 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -111,12 +111,8 @@
 #include <net/tcp.h>
 #include <net/sock.h>
 #include <net/arp.h>
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 #include <net/ax25.h>
-#if defined(CONFIG_NETROM) || defined(CONFIG_NETROM_MODULE)
 #include <net/netrom.h>
-#endif
-#endif
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
 #include <net/atmclip.h>
 struct neigh_table *clip_tbl_hook;
@@ -731,20 +727,10 @@ static int arp_process(struct sk_buff *skb)
 		    htons(dev_type) != arp->ar_hrd)
 			goto out;
 		break;
-#ifdef CONFIG_NET_ETHERNET
 	case ARPHRD_ETHER:
-#endif
-#ifdef CONFIG_TR
 	case ARPHRD_IEEE802_TR:
-#endif
-#ifdef CONFIG_FDDI
 	case ARPHRD_FDDI:
-#endif
-#ifdef CONFIG_NET_FC
 	case ARPHRD_IEEE802:
-#endif
-#if defined(CONFIG_NET_ETHERNET) || defined(CONFIG_TR) || \
-    defined(CONFIG_FDDI)	 || defined(CONFIG_NET_FC)
 		/*
 		 * ETHERNET, Token Ring and Fibre Channel (which are IEEE 802
 		 * devices, according to RFC 2625) devices will accept ARP
@@ -759,21 +745,16 @@ static int arp_process(struct sk_buff *skb)
 		    arp->ar_pro != htons(ETH_P_IP))
 			goto out;
 		break;
-#endif
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 	case ARPHRD_AX25:
 		if (arp->ar_pro != htons(AX25_P_IP) ||
 		    arp->ar_hrd != htons(ARPHRD_AX25))
 			goto out;
 		break;
-#if defined(CONFIG_NETROM) || defined(CONFIG_NETROM_MODULE)
 	case ARPHRD_NETROM:
 		if (arp->ar_pro != htons(AX25_P_IP) ||
 		    arp->ar_hrd != htons(ARPHRD_NETROM))
 			goto out;
 		break;
-#endif
-#endif
 	}
 
 	/* Understand only these message types */
