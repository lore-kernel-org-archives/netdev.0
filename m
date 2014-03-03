From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 21/31] iw_cxgb4: update snd_seq when sending MPA messages.
Date: Mon,  3 Mar 2014 12:11:05 +0530
Message-ID: <1393828875-13452-22-git-send-email-hariprasad@chelsio.com>
References: <1393828875-13452-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, kumaras@chelsio.com,
	dm@chelsio.com, swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, hariprasad@chelsio.com, nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6462 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753866AbaCCGnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 01:43:49 -0500
In-Reply-To: <1393828875-13452-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cm.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 81fbc6e..11c99a6 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -777,6 +777,7 @@ static void send_mpa_req(struct c4iw_ep *ep, struct sk_buff *skb,
 	start_ep_timer(ep);
 	state_set(&ep->com, MPA_REQ_SENT);
 	ep->mpa_attr.initiator = 1;
+	ep->snd_seq += mpalen;
 	return;
 }
 
@@ -856,6 +857,7 @@ static int send_mpa_reject(struct c4iw_ep *ep, const void *pdata, u8 plen)
 	t4_set_arp_err_handler(skb, NULL, arp_failure_discard);
 	BUG_ON(ep->mpa_skb);
 	ep->mpa_skb = skb;
+	ep->snd_seq += mpalen;
 	return c4iw_l2t_send(&ep->com.dev->rdev, skb, ep->l2t);
 }
 
@@ -940,6 +942,7 @@ static int send_mpa_reply(struct c4iw_ep *ep, const void *pdata, u8 plen)
 	t4_set_arp_err_handler(skb, NULL, arp_failure_discard);
 	ep->mpa_skb = skb;
 	state_set(&ep->com, MPA_REP_SENT);
+	ep->snd_seq += mpalen;
 	return c4iw_l2t_send(&ep->com.dev->rdev, skb, ep->l2t);
 }
 
-- 
1.7.1
