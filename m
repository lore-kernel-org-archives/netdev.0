From: Hans de Goede <hdegoede@redhat.com>
Subject: [PATCH 2/2] net: stmmac: Log MAC address only once
Date: Sun, 26 Jan 2014 15:50:44 +0100
Message-ID: <1390747844-25060-2-git-send-email-hdegoede@redhat.com>
References: <1390747844-25060-1-git-send-email-hdegoede@redhat.com>
Cc: netdev@vger.kernel.org, Hans de Goede <hdegoede@redhat.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22066 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752397AbaAZOu4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jan 2014 09:50:56 -0500
In-Reply-To: <1390747844-25060-1-git-send-email-hdegoede@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Logging the MAC address on every if-up, is not really useful, and annoying when
there is no cable inserted and NetworkManager tries the ifup every 50 seconds.

Also change the log level from warning to info, as that is what it is.

Signed-off-by: Hans de Goede <hdegoede@redhat.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 838d0b7..920b3c6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1523,9 +1523,9 @@ static void stmmac_check_ether_addr(struct stmmac_priv *priv)
 					     priv->dev->dev_addr, 0);
 		if (!is_valid_ether_addr(priv->dev->dev_addr))
 			eth_hw_addr_random(priv->dev);
+		pr_info("%s: device MAC address %pM\n", priv->dev->name,
+			priv->dev->dev_addr);
 	}
-	pr_warn("%s: device MAC address %pM\n", priv->dev->name,
-		priv->dev->dev_addr);
 }
 
 /**
-- 
1.8.5.3
