From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 10/10] [bonding 2.6] Fix ipx_hdr compile error
Date: Thu, 11 Sep 2003 17:46:19 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309111746.19979.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c	Thu Sep 11 16:48:44 2003
+++ b/drivers/net/bonding/bond_alb.c	Thu Sep 11 16:48:45 2003
@@ -1329,16 +1329,15 @@ bond_alb_xmit(struct sk_buff *skb, struc
 		hash_size = 16;
 		break;
 
-#ifdef FIXME
 	case ETH_P_IPX:
-		if (skb->nh.ipxh->ipx_checksum !=
+		if (ipx_hdr(skb)->ipx_checksum !=
 		    __constant_htons(IPX_NO_CHECKSUM)) {
 			/* something is wrong with this packet */
 			do_tx_balance = 0;
 			break;
 		}
 
-		if (skb->nh.ipxh->ipx_type !=
+		if (ipx_hdr(skb)->ipx_type !=
 		    __constant_htons(IPX_TYPE_NCP)) {
 			/* The only protocol worth balancing in
 			 * this family since it has an "ARP" like
@@ -1351,7 +1350,6 @@ bond_alb_xmit(struct sk_buff *skb, struc
 		hash_start = (char*)eth_data->h_dest;
 		hash_size = ETH_ALEN;
 		break;
-#endif
 
 	case ETH_P_ARP:
 		do_tx_balance = 0;
