From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 11/20] net-wireless: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:16 -0700
Message-ID: <1302050665-10460-12-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
 <1302050665-10460-3-git-send-email-maheshb@google.com>
 <1302050665-10460-4-git-send-email-maheshb@google.com>
 <1302050665-10460-5-git-send-email-maheshb@google.com>
 <1302050665-10460-6-git-send-email-maheshb@google.com>
 <1302050665-10460-7-git-send-email-maheshb@google.com>
 <1302050665-10460-8-git-send-email-maheshb@google.com>
 <1302050665-10460-9-git-send-email-maheshb@google.com>
 <1302050665-10460-10-git-send-email-maheshb@google.com>
 <1302050665-10460-11-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:54007 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127Ab1DFAox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:53 -0400
In-Reply-To: <1302050665-10460-11-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/wireless/core.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/wireless/core.c b/net/wireless/core.c
index fe01de2..f5b619d 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -235,11 +235,11 @@ int cfg80211_switch_netns(struct cfg80211_registered_device *rdev,
 		return -EOPNOTSUPP;
 
 	list_for_each_entry(wdev, &rdev->netdev_list, list) {
-		wdev->netdev->features &= ~NETIF_F_NETNS_LOCAL;
+		wdev->netdev->legacy_features &= ~NETIF_F_NETNS_LOCAL;
 		err = dev_change_net_namespace(wdev->netdev, net, "wlan%d");
 		if (err)
 			break;
-		wdev->netdev->features |= NETIF_F_NETNS_LOCAL;
+		wdev->netdev->legacy_features |= NETIF_F_NETNS_LOCAL;
 	}
 
 	if (err) {
@@ -248,11 +248,11 @@ int cfg80211_switch_netns(struct cfg80211_registered_device *rdev,
 
 		list_for_each_entry_continue_reverse(wdev, &rdev->netdev_list,
 						     list) {
-			wdev->netdev->features &= ~NETIF_F_NETNS_LOCAL;
+			wdev->netdev->legacy_features &= ~NETIF_F_NETNS_LOCAL;
 			err = dev_change_net_namespace(wdev->netdev, net,
 							"wlan%d");
 			WARN_ON(err);
-			wdev->netdev->features |= NETIF_F_NETNS_LOCAL;
+			wdev->netdev->legacy_features |= NETIF_F_NETNS_LOCAL;
 		}
 
 		return err;
@@ -697,7 +697,7 @@ static int cfg80211_netdev_notifier_call(struct notifier_block * nb,
 		list_add_rcu(&wdev->list, &rdev->netdev_list);
 		rdev->devlist_generation++;
 		/* can only change netns with wiphy */
-		dev->features |= NETIF_F_NETNS_LOCAL;
+		dev->legacy_features |= NETIF_F_NETNS_LOCAL;
 
 		if (sysfs_create_link(&dev->dev.kobj, &rdev->wiphy.dev.kobj,
 				      "phy80211")) {
-- 
1.7.3.1

