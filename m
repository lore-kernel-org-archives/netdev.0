From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 8/9] bnx2x: further annotations
Date: Tue, 20 Jan 2009 21:50:51 -0800
Message-ID: <1232517051.9701.26.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:49189 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753015AbZAUFvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 00:51:01 -0500
Received: by rv-out-0506.google.com with SMTP id k40so3470392rvb.1
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 21:51:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No functional annotations, just documenting the status quo.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/bnx2x_hsi.h  |    8 ++++----
 drivers/net/bnx2x_main.c |   10 +++++-----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 33d6d5d..2834f37 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -1955,10 +1955,10 @@ struct eth_tx_parse_bd {
 #define ETH_TX_PARSE_BD_CWR_FLG_SHIFT 7
 	u8 ip_hlen;
 	s8 cs_offset;
-	u16 total_hlen;
-	u16 lso_mss;
+	__le16 total_hlen;
+	__le16 lso_mss;
 	u16 tcp_pseudo_csum;
-	u16 ip_id;
+	__le16 ip_id;
 	u32 tcp_send_seq;
 };
 
@@ -2424,7 +2424,7 @@ struct tstorm_cam_entry {
 	u16 lsb_mac_addr;
 	u16 middle_mac_addr;
 	u16 msb_mac_addr;
-	u16 flags;
+	__le16 flags;
 #define TSTORM_CAM_ENTRY_PORT_ID (0x1<<0)
 #define TSTORM_CAM_ENTRY_PORT_ID_SHIFT 0
 #define TSTORM_CAM_ENTRY_RSRVVAL0 (0x7<<1)
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 3d0907b..5e5e008 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -468,7 +468,7 @@ static int bnx2x_mc_assert(struct bnx2x *bp)
 static void bnx2x_fw_dump(struct bnx2x *bp)
 {
 	u32 mark, offset;
-	u32 data[9];
+	__be32 data[9];
 	int word;
 
 	mark = REG_RD(bp, MCP_REG_MCPR_SCRATCH + 0xf104);
@@ -479,14 +479,14 @@ static void bnx2x_fw_dump(struct bnx2x *bp)
 		for (word = 0; word < 8; word++)
 			data[word] = htonl(REG_RD(bp, MCP_REG_MCPR_SCRATCH +
 						  offset + 4*word));
-		data[8] = 0x0;
+		data[8] = cpu_to_be32(0);
 		printk(KERN_CONT "%s", (char *)data);
 	}
 	for (offset = 0xF108; offset <= mark - 0x08000000; offset += 0x8*4) {
 		for (word = 0; word < 8; word++)
 			data[word] = htonl(REG_RD(bp, MCP_REG_MCPR_SCRATCH +
 						  offset + 4*word));
-		data[8] = 0x0;
+		data[8] = cpu_to_be32(0);
 		printk(KERN_CONT "%s", (char *)data);
 	}
 	printk("\n" KERN_ERR PFX "end of fw dump\n");
@@ -9699,11 +9699,11 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 						 bd_prod, ++nbd);
 
 		pbd->lso_mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
-		pbd->tcp_send_seq = swab32(tcp_hdr(skb)->seq);
+		pbd->tcp_send_seq = cpu_to_le32(be32_to_cpu(tcp_hdr(skb)->seq));
 		pbd->tcp_flags = pbd_tcp_flags(skb);
 
 		if (xmit_type & XMIT_GSO_V4) {
-			pbd->ip_id = swab16(ip_hdr(skb)->id);
+			pbd->ip_id = cpu_to_le16(be16_to_cpu(ip_hdr(skb)->id));
 			pbd->tcp_pseudo_csum =
 				swab16(~csum_tcpudp_magic(ip_hdr(skb)->saddr,
 							  ip_hdr(skb)->daddr,
-- 
1.6.1.249.g455e5


