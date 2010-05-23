From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH] ieee802154: Fix possible NULL pointer dereference in
	wpan_phy_alloc
Date: Sun, 23 May 2010 15:45:45 +0000
Message-ID: <20100523154545.GA22578@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dbaryshkov@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:59102 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751903Ab0EWPpu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 May 2010 11:45:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for NULL pointer after kzalloc

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
net/ieee802154/wpan-class.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index 3d803a1..1627ef2 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -147,13 +147,15 @@ struct wpan_phy *wpan_phy_alloc(size_t priv_size)
 	struct wpan_phy *phy = kzalloc(sizeof(*phy) + priv_size,
 			GFP_KERNEL);
 
+	if (!phy)
+		goto out;
 	mutex_lock(&wpan_phy_mutex);
 	phy->idx = wpan_phy_idx++;
 	if (unlikely(!wpan_phy_idx_valid(phy->idx))) {
 		wpan_phy_idx--;
 		mutex_unlock(&wpan_phy_mutex);
 		kfree(phy);
-		return NULL;
+		goto out;
 	}
 	mutex_unlock(&wpan_phy_mutex);
 
@@ -168,6 +170,9 @@ struct wpan_phy *wpan_phy_alloc(size_t priv_size)
 	phy->current_page = 0; /* for compatibility */
 
 	return phy;
+
+out:
+	return NULL;
 }
 EXPORT_SYMBOL(wpan_phy_alloc);
 
