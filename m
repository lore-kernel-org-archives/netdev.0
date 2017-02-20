From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v4 08/12] net: ethernet: aquantia: Null pointer check for aq_nic_ndev_alloc.
Date: Mon, 20 Feb 2017 22:36:46 +0300
Message-ID: <1f109726415ae5fc15a9836ba3586f26fe6b860b.1487618263.git.pavel.belous@aquantia.com>
References: <cover.1487618263.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0068.outbound.protection.outlook.com ([104.47.38.68]:52795
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751478AbdBTTiB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 14:38:01 -0500
In-Reply-To: <cover.1487618263.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

We should check for a null pointer for aq_nic_ndev_alloc
instead netdev_priv.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 019bcc7..a8a27c5 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -202,12 +202,13 @@ struct aq_nic_s *aq_nic_alloc_cold(const struct net_device_ops *ndev_ops,
 	int err = 0;
 
 	ndev = aq_nic_ndev_alloc();
-	self = netdev_priv(ndev);
-	if (!self) {
-		err = -EINVAL;
+	if (!ndev) {
+		err = -ENOMEM;
 		goto err_exit;
 	}
 
+	self = netdev_priv(ndev);
+
 	ndev->netdev_ops = ndev_ops;
 	ndev->ethtool_ops = et_ops;
 
-- 
2.7.4
