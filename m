From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v3 net-next 3/4] net: dsa: Add missing master netdev dev_put() calls
Date: Mon,  7 Dec 2015 13:57:34 +0100
Message-ID: <1449493055-29047-4-git-send-email-narmstrong@baylibre.com>
References: <56321D9A.8010109@baylibre.com>
 <1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>
To: davem@davemloft.net, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	fabf@skynet.be, pavel.nakonechny@skitlab.ru, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34080 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755644AbbLGM7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 07:59:10 -0500
Received: by wmvv187 with SMTP id v187so165157601wmv.1
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 04:59:09 -0800 (PST)
In-Reply-To: <1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upon probe failure or unbinding, add missing dev_put() calls.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index d9e0172..d22d303e 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -919,8 +919,10 @@ static int dsa_probe(struct platform_device *pdev)
 	platform_set_drvdata(pdev, dst);
 
 	ret = dsa_setup_dst(dst, dev, &pdev->dev, pd);
-	if (ret)
+	if (ret) {
+		dev_put(dev);
 		goto out;
+	}
 
 	return 0;
 
@@ -940,6 +942,8 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 		if (ds)
 			dsa_switch_destroy(ds);
 	}
+
+	dev_put(dst->master_netdev);
 }
 
 static int dsa_remove(struct platform_device *pdev)
-- 
1.9.1
