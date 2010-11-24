From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 4/8] ethoc: prevent overflow of rx counter
Date: Wed, 24 Nov 2010 14:40:54 +0100
Message-ID: <1290606058-26703-5-git-send-email-jonas@southpole.se>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38151 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754462Ab0KXOCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 09:02:49 -0500
In-Reply-To: <1290606058-26703-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rewind cur_rx to prevent it from overflowing.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 53c03f2..7d1b5d8 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -408,6 +408,9 @@ static int ethoc_rx(struct net_device *dev, int limit)
 	struct ethoc *priv = netdev_priv(dev);
 	int count;
 
+	/* Prevent overflow of priv->cur_rx by rewinding it */	
+	priv->cur_rx = priv->cur_rx % priv->num_rx;
+
 	for (count = 0; count < limit; ++count) {
 		unsigned int entry;
 		struct ethoc_bd bd;
-- 
1.7.1

