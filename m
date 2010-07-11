From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 7/8] tg3: Fix some checkpatch errors
Date: Sun, 11 Jul 2010 12:31:46 -0700
Message-ID: <1278876707-21390-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1311 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754841Ab0GKTcD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jul 2010 15:32:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following checkpatch errors:

ERROR: do not use assignment in if condition
+	if ((mss = skb_shinfo(skb)->gso_size) != 0) {

ERROR: do not use assignment in if condition
+	if ((mss = skb_shinfo(skb)->gso_size) != 0) {

ERROR: space prohibited after that '!' (ctx:BxW)
+			if (! netif_carrier_ok(tp->dev) &&
 			    ^

ERROR: space required after that ',' (ctx:VxV)
+#define GET_REG32_LOOP(base,len)		\
                            ^

ERROR: "(foo*)" should be "(foo *)"
+		memcpy(data, ((char*)&val) + b_offset, b_count);

ERROR: do not use assignment in if condition
+		if ((err = tg3_do_mem_test(tp, mem_tbl[i].offset,

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f61a4d8..7116a47 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5574,8 +5574,8 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 
 	entry = tnapi->tx_prod;
 	base_flags = 0;
-	mss = 0;
-	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
+	mss = skb_shinfo(skb)->gso_size;
+	if (mss) {
 		int tcp_opt_len, ip_tcp_len;
 		u32 hdrlen;
 
@@ -5781,7 +5781,8 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
 
-	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
+	mss = skb_shinfo(skb)->gso_size;
+	if (mss) {
 		struct iphdr *iph;
 		u32 tcp_opt_len, hdr_len;
 
@@ -8514,7 +8515,7 @@ static void tg3_timer(unsigned long __opaque)
 			    (mac_stat & MAC_STATUS_LNKSTATE_CHANGED)) {
 				need_setup = 1;
 			}
-			if (! netif_carrier_ok(tp->dev) &&
+			if (!netif_carrier_ok(tp->dev) &&
 			    (mac_stat & (MAC_STATUS_PCS_SYNCED |
 					 MAC_STATUS_SIGNAL_DET))) {
 				need_setup = 1;
@@ -9372,7 +9373,7 @@ static void tg3_get_regs(struct net_device *dev,
 	tg3_full_lock(tp, 0);
 
 #define __GET_REG32(reg)	(*(p)++ = tr32(reg))
-#define GET_REG32_LOOP(base,len)		\
+#define GET_REG32_LOOP(base, len)		\
 do {	p = (u32 *)(orig_p + (base));		\
 	for (i = 0; i < len; i += 4)		\
 		__GET_REG32((base) + i);	\
@@ -9465,7 +9466,7 @@ static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 		ret = tg3_nvram_read_be32(tp, offset-b_offset, &val);
 		if (ret)
 			return ret;
-		memcpy(data, ((char*)&val) + b_offset, b_count);
+		memcpy(data, ((char *)&val) + b_offset, b_count);
 		len -= b_count;
 		offset += b_count;
 		eeprom->len += b_count;
@@ -10585,8 +10586,8 @@ static int tg3_test_memory(struct tg3 *tp)
 		mem_tbl = mem_tbl_570x;
 
 	for (i = 0; mem_tbl[i].offset != 0xffffffff; i++) {
-		if ((err = tg3_do_mem_test(tp, mem_tbl[i].offset,
-		    mem_tbl[i].len)) != 0)
+		err = tg3_do_mem_test(tp, mem_tbl[i].offset, mem_tbl[i].len);
+		if (err)
 			break;
 	}
 
-- 
1.6.4.4


