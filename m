From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v4 3/3] macvtap: Ignore tap features when VNET_HDR is off
Date: Fri, 16 Aug 2013 15:25:02 -0400
Message-ID: <1376681102-19753-4-git-send-email-vyasevic@redhat.com>
References: <1376681102-19753-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16489 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754156Ab3HPW0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Aug 2013 18:26:51 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7GJP8HT018583
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 15:25:08 -0400
In-Reply-To: <1376681102-19753-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the user turns off VNET_HDR support on the
macvtap device, there is no way to provide any
offload information to the user.  So, it's safer
to ignore offload setting then depend on the user
setting them correctly.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvtap.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 4acfbce..ea53abb 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -290,9 +290,11 @@ static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
 
 	skb->dev = dev;
 	/* Apply the forward feature mask so that we perform segmentation
-	 * according to users wishes.
+	 * according to users wishes.  This only works if VNET_HDR is
+	 * enabled.
 	 */
-	features |= vlan->tap_features;
+	if (q->flags & IFF_VNET_HDR)
+		features |= vlan->tap_features;
 	if (netif_needs_gso(skb, features)) {
 		struct sk_buff *segs = __skb_gso_segment(skb, features, false);
 
-- 
1.8.1.4
