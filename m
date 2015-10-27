From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH 4/6] net: dsa: Add missing master netdev dev_put() calls
Date: Tue, 27 Oct 2015 15:49:09 +0100
Message-ID: <562F8EE5.6070907@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Upon probe failure or unbinding, add missing dev_put() calls.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index acbf854..9240a46 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -931,8 +931,10 @@ static int dsa_probe(struct platform_device *pdev)
 	platform_set_drvdata(pdev, dst);

 	ret = dsa_setup_dst(dst, dev, &pdev->dev, pd);
-	if (ret)
+	if (ret) {
+		dev_put(dev);
 		goto out;
+	}

 	return 0;

@@ -965,6 +967,8 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 		if (ds)
 			dsa_switch_destroy(ds);
 	}
+
+	dev_put(dst->master_netdev);
 }

 static int dsa_remove(struct platform_device *pdev)
-- 
1.9.1
