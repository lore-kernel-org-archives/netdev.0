From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] tg3: Allow for receive of full-size 8021AD frames
Date: Tue, 30 Sep 2014 14:53:08 -0400
Message-ID: <542AFC14.6030304@redhat.com>
References: <1411165389-21276-1-git-send-email-vyasevic@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51226 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752273AbaI3SxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 14:53:11 -0400
In-Reply-To: <1411165389-21276-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When receiving a vlan-tagged frame that still contains
a vlan header, the length of the packet will be greater
then MTU+ETH_HLEN since it will account of the extra
vlan header.  TG3 checks this for the case for 802.1Q,
but not for 802.1ad.  As a result, full sized 802.1ad
frames get dropped by the card.

Add a check for 802.1ad protocol when receiving full
sized frames.

Suggested-by: Prashant Sreedharan <prashant@broadcom.com>
CC: Prashant Sreedharan <prashant@broadcom.com>
CC: Michael Chan <mchan@broadcom.com>
Acked-by: Prashant Sreedharan <prashant@broadcom.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
This patch somehow got dropped.  Please apply and queue for stable.

 drivers/net/ethernet/broadcom/tg3.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0a0938d..4f674f9 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6918,7 +6918,8 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		skb->protocol = eth_type_trans(skb, tp->dev);
  		if (len > (tp->dev->mtu + ETH_HLEN) &&
-		    skb->protocol != htons(ETH_P_8021Q)) {
+		    skb->protocol != htons(ETH_P_8021Q) &&
+		    skb->protocol != htons(ETH_P_8021AD)) {
 			dev_kfree_skb_any(skb);
 			goto drop_it_no_recycle;
 		}
-- 
1.9.3
