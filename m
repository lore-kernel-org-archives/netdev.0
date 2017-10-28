From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] phylink: Use common error handling code in phylink_create()
Date: Sat, 28 Oct 2017 22:00:33 +0200
Message-ID: <f52bdf2b-d45f-7db4-b533-d96dd3b4f6bf@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 28 Oct 2017 21:48:31 +0200

* Add a jump target so that a bit of exception handling can be better
  reused at the end of this function.

* Adjust three condition checks.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/phy/phylink.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/phy/phylink.c b/drivers/net/phy/phylink.c
index bcb4755bcd95..67b19c13f405 100644
--- a/drivers/net/phy/phylink.c
+++ b/drivers/net/phy/phylink.c
@@ -533,26 +533,24 @@ struct phylink *phylink_create(struct net_device *ndev, struct device_node *np,
 	phylink_validate(pl, pl->supported, &pl->link_config);
 
 	ret = phylink_parse_mode(pl, np);
-	if (ret < 0) {
-		kfree(pl);
-		return ERR_PTR(ret);
-	}
+	if (ret)
+		goto free_link;
 
 	if (pl->link_an_mode == MLO_AN_FIXED) {
 		ret = phylink_parse_fixedlink(pl, np);
-		if (ret < 0) {
-			kfree(pl);
-			return ERR_PTR(ret);
-		}
+		if (ret)
+			goto free_link;
 	}
 
 	ret = phylink_register_sfp(pl, np);
-	if (ret < 0) {
-		kfree(pl);
-		return ERR_PTR(ret);
-	}
+	if (ret)
+		goto free_link;
 
 	return pl;
+
+free_link:
+	kfree(pl);
+	return ERR_PTR(ret);
 }
 EXPORT_SYMBOL_GPL(phylink_create);
 
-- 
2.14.3
