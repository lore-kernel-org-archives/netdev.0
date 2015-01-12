From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/8] net: phy: fixed: allow setting no update_link callback
Date: Mon, 12 Jan 2015 13:57:41 -0800
Message-ID: <1421099866-3184-4-git-send-email-f.fainelli@gmail.com>
References: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:40820 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbbALV55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:57:57 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so32612931pdb.10
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 13:57:56 -0800 (PST)
In-Reply-To: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fixed_phy_set_link_update() contains an early check against a NULL
callback pointer, which basically prevents us from removing any
previous callback we may have set. The users of the fp->link_update
callback deal with a NULL callback just fine.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/fixed_phy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index 3ad0e6e16c39..a08a3c78ba97 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -168,7 +168,7 @@ int fixed_phy_set_link_update(struct phy_device *phydev,
 	struct fixed_mdio_bus *fmb = &platform_fmb;
 	struct fixed_phy *fp;
 
-	if (!link_update || !phydev || !phydev->bus)
+	if (!phydev || !phydev->bus)
 		return -EINVAL;
 
 	list_for_each_entry(fp, &fmb->phys, node) {
-- 
2.1.0
