From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v2 4/6] net: dsa: Add missing master netdev dev_put() calls
Date: Thu, 29 Oct 2015 14:23:20 +0100
Message-ID: <56321DC8.9020101@baylibre.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33995 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932528AbbJ2NX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 09:23:26 -0400
Received: by wikq8 with SMTP id q8so284224352wik.1
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 06:23:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upon probe failure or unbinding, add missing dev_put() calls on
master netdev.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index b2f696c..597a462 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -928,8 +928,10 @@ static int dsa_probe(struct platform_device *pdev)
 	platform_set_drvdata(pdev, dst);

 	ret = dsa_setup_dst(dst, dev, &pdev->dev, pd);
-	if (ret)
+	if (ret) {
+		dev_put(dev);
 		goto out;
+	}

 	return 0;

@@ -963,6 +965,8 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 		if (ds)
 			dsa_switch_destroy(ds);
 	}
+
+	dev_put(dst->master_netdev);
 }

 static int dsa_remove(struct platform_device *pdev)
-- 
1.9.1
