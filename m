From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC][PATCH 3/3] net: add SKB_SOL control messages
Date: Thu, 24 Jul 2008 01:01:04 +0300
Message-ID: <1216850464-30000-4-git-send-email-opurdila@ixiacom.com>
References: <1216850464-30000-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1937 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753640AbYGWWDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 18:03:33 -0400
In-Reply-To: <1216850464-30000-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SKB_RX_GET_TSTAMP - get hardware timestamp at receive time
SKB_TX_GET_TSTAMP - get hardware timestamp at transmit time
SKB_TX_SCHED - schedule packet to be transmited at hardware timestamp
SKB_TX_EMBED_TSTAMP - embed hardware timestamp into packet at
                    transmit time

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/linux/skb_cmsg.h |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/skb_cmsg.h

diff --git a/include/linux/skb_cmsg.h b/include/linux/skb_cmsg.h
new file mode 100644
index 0000000..c5b8a9b
--- /dev/null
+++ b/include/linux/skb_cmsg.h
@@ -0,0 +1,28 @@
+#ifndef _LINUX_SKB_CMSG_H
+#define _LINUX_SKB_CMSG_H
+
+#define SKB_RX_GET_TSTAMP      1
+#define SKB_TX_GET_TSTAMP      2
+#define SKB_TX_SCHED           3
+#define SKB_TX_EMBED_TSTAMP    4
+
+struct skb_rx_tstamp {
+       __u64 tstamp;
+};
+
+struct skb_tx_tstamp {
+       __u64 tstamp, cookie;
+};
+
+struct skb_tx_sched {
+       __u64 tstamp;
+};
+
+#define SKB_TX_EMBED_TSTAMP_OFFSET_EOP 0x00010000
+
+struct skb_tx_embed_tstamp {
+       __u64 mask;
+       __u32 offset;
+};
+
+#endif
-- 
1.5.6.2

