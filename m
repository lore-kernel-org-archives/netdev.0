From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 03/11] bnx2x: Call dev_kfree_skby_any instead of dev_kfree_skb.
Date: Mon, 10 Mar 2014 20:19:23 -0700
Message-ID: <87k3c1pglg.fsf_-_@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
	<871ty9qvaf.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:37618 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754406AbaCKDT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:19:28 -0400
In-Reply-To: <871ty9qvaf.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 10 Mar 2014 20:16:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace dev_kfree_skb with dev_kfree_skb_any in functions that can
be called in hard irq and other contexts.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 117b5c7f8ac9..ebe5ae2b961e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3719,7 +3719,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			struct bnx2x_eth_q_stats *q_stats =
 				bnx2x_fp_qstats(bp, txdata->parent_fp);
 			q_stats->driver_filtered_tx_pkt++;
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			return NETDEV_TX_OK;
 		}
 		bnx2x_fp_qstats(bp, txdata->parent_fp)->driver_xoff++;
-- 
1.7.5.4
