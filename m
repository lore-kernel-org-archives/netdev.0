From: greearb@candelatech.com
Subject: [PATCH 07/10] ath9k: Add tx-failed counter.
Date: Wed, 11 Apr 2012 10:52:15 -0700
Message-ID: <1334166738-28243-8-git-send-email-greearb@candelatech.com>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40903 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932416Ab2DKRxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 13:53:32 -0400
In-Reply-To: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This counts any failure during getting packets into
the DMA buffers, including out-of-memory, etc.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 ff47b32... 186efc5... M	drivers/net/wireless/ath/ath9k/debug.c
:100644 100644 2d47f74... fe2b487... M	drivers/net/wireless/ath/ath9k/debug.h
:100644 100644 39f8f7c... c18290a... M	drivers/net/wireless/ath/ath9k/main.c
 drivers/net/wireless/ath/ath9k/debug.c |    1 +
 drivers/net/wireless/ath/ath9k/debug.h |    2 ++
 drivers/net/wireless/ath/ath9k/main.c  |    1 +
 3 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/ath/ath9k/debug.c
index ff47b32..186efc5 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -524,6 +524,7 @@ static ssize_t read_file_xmit(struct file *file, char __user *user_buf,
 	PR("hw-put-tx-buf:   ", puttxbuf);
 	PR("hw-tx-start:     ", txstart);
 	PR("hw-tx-proc-desc: ", txprocdesc);
+	PR("TX-Failed:       ", txfailed);
 	len += snprintf(buf + len, size - len,
 			"%s%11p%11p%10p%10p\n", "txq-memory-address:",
 			sc->tx.txq_map[WME_AC_BE],
diff --git a/drivers/net/wireless/ath/ath9k/debug.h b/drivers/net/wireless/ath/ath9k/debug.h
index 2d47f74..fe2b487 100644
--- a/drivers/net/wireless/ath/ath9k/debug.h
+++ b/drivers/net/wireless/ath/ath9k/debug.h
@@ -113,6 +113,7 @@ struct ath_interrupt_stats {
  * @puttxbuf: Number of times hardware was given txbuf to write.
  * @txstart:  Number of times hardware was told to start tx.
  * @txprocdesc:  Number of times tx descriptor was processed
+ * @txfailed:  Out-of-memory or other errors in xmit path.
  */
 struct ath_tx_stats {
 	u32 tx_pkts_all;
@@ -135,6 +136,7 @@ struct ath_tx_stats {
 	u32 puttxbuf;
 	u32 txstart;
 	u32 txprocdesc;
+	u32 txfailed;
 };
 
 /**
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 39f8f7c..c18290a 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1150,6 +1150,7 @@ static void ath9k_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 
 	if (ath_tx_start(hw, skb, &txctl) != 0) {
 		ath_dbg(common, XMIT, "TX failed\n");
+		TX_STAT_INC(txctl.txq->axq_qnum, txfailed);
 		goto exit;
 	}
 
-- 
1.7.3.4
