From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 07/20] net-dsa: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:12 -0700
Message-ID: <1302050665-10460-8-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
 <1302050665-10460-3-git-send-email-maheshb@google.com>
 <1302050665-10460-4-git-send-email-maheshb@google.com>
 <1302050665-10460-5-git-send-email-maheshb@google.com>
 <1302050665-10460-6-git-send-email-maheshb@google.com>
 <1302050665-10460-7-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:54004 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079Ab1DFAow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:52 -0400
In-Reply-To: <1302050665-10460-7-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/dsa/slave.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 64ca2a6..fb40250 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -349,7 +349,7 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	if (slave_dev == NULL)
 		return slave_dev;
 
-	slave_dev->features = master->vlan_features;
+	slave_dev->legacy_features = master->legacy_vlan_features;
 	SET_ETHTOOL_OPS(slave_dev, &dsa_slave_ethtool_ops);
 	memcpy(slave_dev->dev_addr, master->dev_addr, ETH_ALEN);
 	slave_dev->tx_queue_len = 0;
@@ -375,7 +375,7 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	}
 
 	SET_NETDEV_DEV(slave_dev, parent);
-	slave_dev->vlan_features = master->vlan_features;
+	slave_dev->legacy_vlan_features = master->legacy_vlan_features;
 
 	p = netdev_priv(slave_dev);
 	p->dev = slave_dev;
-- 
1.7.3.1

