From: Bart De Schuymer <bdschuym@pandora.be>
Subject: [PATCH] Always copy and save the vlan header in bridge-nf (do it right now)
Date: Wed, 31 Dec 2003 11:56:11 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312311156.11241.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, Tomas Szepe <szepe@pinerecords.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

I forgot to get rid of another ifdef in netfilter_bridge.h when I removed
the dependency upon vlan being compiled. This patch fixes it.

cheers,
Bart

--- linux-2.6.0-bk3/include/linux/netfilter_bridge.h.earlier	2003-12-31 11:54:25.000000000 +0100
+++ linux-2.6.0-bk3/include/linux/netfilter_bridge.h	2003-12-31 11:54:47.000000000 +0100
@@ -8,10 +8,8 @@
 #include <linux/netfilter.h>
 #if defined(__KERNEL__) && defined(CONFIG_BRIDGE_NETFILTER)
 #include <asm/atomic.h>
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #include <linux/if_ether.h>
 #endif
-#endif
 
 /* Bridge Hooks */
 /* After promisc drops, checksum checks. */
