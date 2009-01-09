From: frank.blaschka@de.ibm.com
Subject: [patch 1/4] lcs: convert to net_device_ops
Date: Fri, 09 Jan 2009 10:01:57 +0100
Message-ID: <20090109090220.554541000@de.ibm.com>
References: <20090109090156.422658000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:60968 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633AbZAIJCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 04:02:23 -0500
Content-Disposition: inline; filename=lcs_devops.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

lcs convert to net_device_ops.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/lcs.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

Index: git_linus/drivers/s390/net/lcs.c
===================================================================
--- git_linus.orig/drivers/s390/net/lcs.c
+++ git_linus/drivers/s390/net/lcs.c
@@ -2097,6 +2097,12 @@ lcs_register_netdev(struct ccwgroup_devi
 /**
  * lcs_new_device will be called by setting the group device online.
  */
+static struct net_device_ops lcs_netdev_ops = {
+	.ndo_open		= lcs_open_device,
+	.ndo_stop		= lcs_stop_device,
+	.ndo_get_stats		= lcs_getstats,
+	.ndo_start_xmit		= lcs_start_xmit,
+};
 
 static int
 lcs_new_device(struct ccwgroup_device *ccwgdev)
@@ -2164,14 +2170,11 @@ lcs_new_device(struct ccwgroup_device *c
 		goto out;
 	card->dev = dev;
 	card->dev->ml_priv = card;
-	card->dev->open = lcs_open_device;
-	card->dev->stop = lcs_stop_device;
-	card->dev->hard_start_xmit = lcs_start_xmit;
-	card->dev->get_stats = lcs_getstats;
+	card->dev->netdev_ops = &lcs_netdev_ops;
 	memcpy(card->dev->dev_addr, card->mac, LCS_MAC_LENGTH);
 #ifdef CONFIG_IP_MULTICAST
 	if (!lcs_check_multicast_support(card))
-		card->dev->set_multicast_list = lcs_set_multicast_list;
+		lcs_netdev_ops.ndo_set_multicast_list = lcs_set_multicast_list;
 #endif
 netdev_out:
 	lcs_set_allowed_threads(card,0xffffffff);

-- 
