From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH] [bonding 2.6] Fix compilation warning in bond_alb.c
Date: Wed, 31 Dec 2003 11:21:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312311121.52132.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The IPX_TYPE_* constants and ipxhdr.ipx_type are u8 values, so we
shouldn't use __constant_htons().


diff -Nuarp a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c	Tue Dec 30 19:25:43 2003
+++ b/drivers/net/bonding/bond_alb.c	Tue Dec 30 19:25:44 2003
@@ -1228,8 +1228,7 @@ int bond_alb_xmit(struct sk_buff *skb, s
 			break;
 		}
 
-		if (ipx_hdr(skb)->ipx_type !=
-		    __constant_htons(IPX_TYPE_NCP)) {
+		if (ipx_hdr(skb)->ipx_type != IPX_TYPE_NCP) {
 			/* The only protocol worth balancing in
 			 * this family since it has an "ARP" like
 			 * mechanism
