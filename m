From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] mac802154: constify ieee802154_llsec_ops structure
Date: Wed, 23 Dec 2015 22:36:32 +0100
Message-ID: <1450906592-9203-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-wpan@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ieee802154_llsec_ops structure is never modified, so declare it as
const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 include/net/ieee802154_netdev.h |    2 +-
 net/mac802154/mac_cmd.c         |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index a62a051..c4b3160 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -337,7 +337,7 @@ struct ieee802154_mlme_ops {
 	void (*get_mac_params)(struct net_device *dev,
 			       struct ieee802154_mac_params *params);
 
-	struct ieee802154_llsec_ops *llsec;
+	const struct ieee802154_llsec_ops *llsec;
 };
 
 static inline struct ieee802154_mlme_ops *
diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
index 8606da4..3db1634 100644
--- a/net/mac802154/mac_cmd.c
+++ b/net/mac802154/mac_cmd.c
@@ -126,7 +126,7 @@ static void mac802154_get_mac_params(struct net_device *dev,
 	params->lbt = wpan_dev->lbt;
 }
 
-static struct ieee802154_llsec_ops mac802154_llsec_ops = {
+static const struct ieee802154_llsec_ops mac802154_llsec_ops = {
 	.get_params = mac802154_get_params,
 	.set_params = mac802154_set_params,
 	.add_key = mac802154_add_key,
