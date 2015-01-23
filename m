From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v3 5/5] bonding: handle NETIF_F_HW_NETFUNC_OFFLOAD flag to bonding feature mask
Date: Thu, 22 Jan 2015 20:33:26 -0800
Message-ID: <1421987606-10884-6-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:46104 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386AbbAWEdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 23:33:36 -0500
Received: by mail-pa0-f47.google.com with SMTP id lj1so6068445pab.6
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 20:33:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

We want bond to pick up the offload flag if any of its slaves have it.

NETIF_F_HW_NETFUNC_OFFLOAD flag is added to the mask, so that
netdev_increment_features does not ignore it.

If this needs to be under CONFIG_NET_SWITCHDEV, I can do so.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/bonding/bond_main.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 184c434..4304194 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -979,7 +979,11 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 	netdev_features_t mask;
 	struct slave *slave;
 
-	mask = features;
+	/* If any slave has the offload feature flag set,
+	 * set the offload flag on the bond.
+	 */
+	mask = features | NETIF_F_HW_NETFUNC_OFFLOAD;
+
 	features &= ~NETIF_F_ONE_FOR_ALL;
 	features |= NETIF_F_ALL_FOR_ALL;
 
-- 
1.7.10.4
