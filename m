From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 14/18] igb: minor type cleanups
Date: Wed, 17 Feb 2010 03:04:56 -0800
Message-ID: <20100217110455.17723.55924.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:50458 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754885Ab0BQLFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:05:14 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

This change cleans up some instances where unsigned int and u32
were being used interchangeably, and cleans up hdr_len which
was being set to 0 twice.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 91c123f..ff392e9 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3434,8 +3434,8 @@ static inline int igb_tso_adv(struct igb_ring *tx_ring,
 	int err;
 	struct igb_buffer *buffer_info;
 	u32 info = 0, tu_cmd = 0;
-	u32 mss_l4len_idx, l4len;
-	*hdr_len = 0;
+	u32 mss_l4len_idx;
+	u8 l4len;
 
 	if (skb_header_cloned(skb)) {
 		err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
@@ -3671,7 +3671,7 @@ dma_error:
 }
 
 static inline void igb_tx_queue_adv(struct igb_ring *tx_ring,
-				    int tx_flags, int count, u32 paylen,
+				    u32 tx_flags, int count, u32 paylen,
 				    u8 hdr_len)
 {
 	union e1000_adv_tx_desc *tx_desc;
@@ -3770,10 +3770,10 @@ netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
 				    struct igb_ring *tx_ring)
 {
 	struct igb_adapter *adapter = netdev_priv(tx_ring->netdev);
-	unsigned int first;
-	unsigned int tx_flags = 0;
-	u8 hdr_len = 0;
 	int tso = 0, count;
+	u32 tx_flags = 0;
+	u16 first;
+	u8 hdr_len = 0;
 	union skb_shared_tx *shtx = skb_tx(skb);
 
 	/* need: 1 descriptor per page,

