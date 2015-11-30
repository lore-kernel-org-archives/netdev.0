From: Kamal Mostafa <kamal@canonical.com>
Subject: [3.19.y-ckt stable] Patch "can: Use correct type in sizeof() in nla_put()" has been added to staging queue
Date: Mon, 30 Nov 2015 14:09:48 -0800
Message-ID: <1448921388-10476-1-git-send-email-kamal@canonical.com>
Cc: Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Kamal Mostafa <kamal@canonical.com>,
	kernel-team@lists.ubuntu.com
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:54009 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754187AbbK3WJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 17:09:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a note to let you know that I have just added a patch titled

    can: Use correct type in sizeof() in nla_put()

to the linux-3.19.y-queue branch of the 3.19.y-ckt extended stable tree 
which can be found at:

    http://kernel.ubuntu.com/git/ubuntu/linux.git/log/?h=linux-3.19.y-queue

This patch is scheduled to be released in version 3.19.8-ckt11.

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.19.y-ckt tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Kamal

------

>From 6226f4073973c9a2945e3c68bf04b0f8cc0c0793 Mon Sep 17 00:00:00 2001
From: Marek Vasut <marex@denx.de>
Date: Fri, 30 Oct 2015 13:48:19 +0100
Subject: can: Use correct type in sizeof() in nla_put()

commit 562b103a21974c2f9cd67514d110f918bb3e1796 upstream.

The sizeof() is invoked on an incorrect variable, likely due to some
copy-paste error, and this might result in memory corruption. Fix this.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Wolfgang Grandegger <wg@grandegger.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Signed-off-by: Kamal Mostafa <kamal@canonical.com>
---
 drivers/net/can/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 62ca0e8..8202ab3 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -912,7 +912,7 @@ static int can_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	     nla_put(skb, IFLA_CAN_BITTIMING_CONST,
 		     sizeof(*priv->bittiming_const), priv->bittiming_const)) ||

-	    nla_put(skb, IFLA_CAN_CLOCK, sizeof(cm), &priv->clock) ||
+	    nla_put(skb, IFLA_CAN_CLOCK, sizeof(priv->clock), &priv->clock) ||
 	    nla_put_u32(skb, IFLA_CAN_STATE, state) ||
 	    nla_put(skb, IFLA_CAN_CTRLMODE, sizeof(cm), &cm) ||
 	    nla_put_u32(skb, IFLA_CAN_RESTART_MS, priv->restart_ms) ||
--
1.9.1
