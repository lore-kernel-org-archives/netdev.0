From: Luis Henriques <luis.henriques@canonical.com>
Subject: [3.16.y-ckt stable] Patch "can: Use correct type in sizeof() in nla_put()" has been added to staging queue
Date: Mon, 30 Nov 2015 12:32:51 +0000
Message-ID: <1448886771-15125-1-git-send-email-luis.henriques@canonical.com>
Cc: Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Luis Henriques <luis.henriques@canonical.com>,
	kernel-team@lists.ubuntu.com
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:48016 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbbK3Mcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 07:32:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a note to let you know that I have just added a patch titled

    can: Use correct type in sizeof() in nla_put()

to the linux-3.16.y-queue branch of the 3.16.y-ckt extended stable tree 
which can be found at:

    http://kernel.ubuntu.com/git/ubuntu/linux.git/log/?h=linux-3.16.y-queue

This patch is scheduled to be released in version 3.16.7-ckt21.

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.16.y-ckt tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Luis

------

>From 38c6b0cfa61cf90117c73fba15a90478085d9e48 Mon Sep 17 00:00:00 2001
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
Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
---
 drivers/net/can/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index c543c3aaee4d..5635c6e7af57 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -835,7 +835,7 @@ static int can_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	     nla_put(skb, IFLA_CAN_BITTIMING_CONST,
 		     sizeof(*priv->bittiming_const), priv->bittiming_const)) ||

-	    nla_put(skb, IFLA_CAN_CLOCK, sizeof(cm), &priv->clock) ||
+	    nla_put(skb, IFLA_CAN_CLOCK, sizeof(priv->clock), &priv->clock) ||
 	    nla_put_u32(skb, IFLA_CAN_STATE, state) ||
 	    nla_put(skb, IFLA_CAN_CTRLMODE, sizeof(cm), &cm) ||
 	    nla_put_u32(skb, IFLA_CAN_RESTART_MS, priv->restart_ms) ||
