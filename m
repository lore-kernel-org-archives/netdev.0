From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc9420: fix big endian rx checksum offload
Date: Thu, 19 Mar 2009 11:12:32 +0000
Message-ID: <1237461152-5519-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:56413 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752052AbZCSLMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 07:12:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The cpu_to_le16 here looks suspicious to me, I don't think we need it
because put_unaligned_le16 also does this.

I don't currently have any big endian hardware with a PCI bus available
to test on, so I haven't been able to verify this.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc9420.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 17560db..5959ae8 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -807,7 +807,7 @@ static void smsc9420_rx_handoff(struct smsc9420_pdata *pd, const int index,
 	if (pd->rx_csum) {
 		u16 hw_csum = get_unaligned_le16(skb_tail_pointer(skb) +
 			NET_IP_ALIGN + packet_length + 4);
-		put_unaligned_le16(cpu_to_le16(hw_csum), &skb->csum);
+		put_unaligned_le16(hw_csum, &skb->csum);
 		skb->ip_summed = CHECKSUM_COMPLETE;
 	}
 
-- 
1.6.0.6

