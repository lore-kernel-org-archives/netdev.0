From: Simon Horman <horms@verge.net.au>
Subject: [patch net-next] net: increase the size of priv_flags and add
 IFF_OVS_DATAPATH
Date: Tue, 24 Aug 2010 11:26:41 +0900
Message-ID: <20100824022637.GA11820@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:44027 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227Ab0HXC0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 22:26:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFF_OVS_DATAPATH is a place-holder for the Open vSwitch datapath
which I am preparing to submit for merging.

As all 16 bits of priv_flags are already assigned flags, also increase
the size of priv_flags to 32 bits.

Unfortunately, by my calculations this increases the size of
struct net_device by 4 bytes on 32bit architectures and
8 bytes on 64 bit architectures. I couldn't see an obvious
way to avoid that.

Cc: Jesse Gross <jesse@nicira.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

I had hoped this patch would be much cleaner :^)

Index: nf-next-2.6/include/linux/if.h
===================================================================
--- nf-next-2.6.orig/include/linux/if.h	2010-08-24 10:29:41.000000000 +0900
+++ nf-next-2.6/include/linux/if.h	2010-08-24 11:11:39.000000000 +0900
@@ -75,6 +75,8 @@
 #define IFF_DISABLE_NETPOLL	0x2000	/* disable netpoll at run-time */
 #define IFF_MACVLAN_PORT	0x4000	/* device used as macvlan port */
 #define IFF_BRIDGE_PORT	0x8000		/* device used as bridge port */
+#define IFF_OVS_DATAPATH	0x10000	/* device used as Open vSwitch
+					 * dapath port */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
Index: nf-next-2.6/include/linux/netdevice.h
===================================================================
--- nf-next-2.6.orig/include/linux/netdevice.h	2010-08-24 10:38:14.000000000 +0900
+++ nf-next-2.6/include/linux/netdevice.h	2010-08-24 11:11:14.000000000 +0900
@@ -907,7 +907,7 @@ struct net_device {
 
 	unsigned int		flags;	/* interface flags (a la BSD)	*/
 	unsigned short		gflags;
-        unsigned short          priv_flags; /* Like 'flags' but invisible to userspace. */
+        unsigned int            priv_flags; /* Like 'flags' but invisible to userspace. */
 	unsigned short		padded;	/* How much padding added by alloc_netdev() */
 
 	unsigned char		operstate; /* RFC2863 operstate */
