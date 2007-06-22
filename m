From: Patrick McHardy <kaber@trash.net>
Subject: [NET 01/05]: dev_mcast: unexport dev_mc_upload
Date: Fri, 22 Jun 2007 14:24:07 +0200 (MEST)
Message-ID: <20070622122332.15215.1295.sendpatchset@localhost.localdomain>
References: <20070622122330.15215.47821.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62391 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbXFVMYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 08:24:08 -0400
In-Reply-To: <20070622122330.15215.47821.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: dev_mcast: unexport dev_mc_upload

dev_mc_add/dev_mc_delete take care of uploading the list when
necessary and thats the only interface other code should use.
Also remove two incorrect calls in DECnet.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit cdf660f0bd4cca9d2cbe86a31adc60d6fa8a60ec
tree 2f08c8240b7da9b17725896c3f7eb9c7a960c92c
parent 45da27ba265dba3c740c45d47f584c30d7066f82
author Patrick McHardy <kaber@trash.net> Fri, 22 Jun 2007 00:56:00 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 22 Jun 2007 00:56:00 +0200

 net/core/dev_mcast.c |    1 -
 net/decnet/dn_dev.c  |    3 ---
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index 5a54053..80bb2e3 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -292,4 +292,3 @@ void __init dev_mcast_init(void)
 
 EXPORT_SYMBOL(dev_mc_add);
 EXPORT_SYMBOL(dev_mc_delete);
-EXPORT_SYMBOL(dev_mc_upload);
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index ab41c18..e31549e 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -461,7 +461,6 @@ static int dn_dev_insert_ifa(struct dn_dev *dn_db, struct dn_ifaddr *ifa)
 		if (ifa->ifa_local != dn_eth2dn(dev->dev_addr)) {
 			dn_dn2eth(mac_addr, ifa->ifa_local);
 			dev_mc_add(dev, mac_addr, ETH_ALEN, 0);
-			dev_mc_upload(dev);
 		}
 	}
 
@@ -1064,8 +1063,6 @@ static int dn_eth_up(struct net_device *dev)
 	else
 		dev_mc_add(dev, dn_rt_all_rt_mcast, ETH_ALEN, 0);
 
-	dev_mc_upload(dev);
-
 	dn_db->use_long = 1;
 
 	return 0;
