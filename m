From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v3 1/5] net: dsa: add missing kfree on remove
Date: Tue, 6 Oct 2015 15:39:53 +0100
Message-ID: <5613DD39.4000502@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To prevent memory leakage on unbinding, add missing kfree calls.
Includes minor cosmetic change to make patch clean.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index c59fa5d..ed9d43f 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -914,8 +914,10 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 	for (i = 0; i < dst->pd->nr_chips; i++) {
 		struct dsa_switch *ds = dst->ds[i];

-		if (ds != NULL)
+		if (ds) {
 			dsa_switch_destroy(ds);
+			kfree(ds);
+		}
 	}
 }

@@ -924,6 +926,7 @@ static int dsa_remove(struct platform_device *pdev)
 	struct dsa_switch_tree *dst = platform_get_drvdata(pdev);

 	dsa_remove_dst(dst);
+	kfree(dst);
 	dsa_of_remove(&pdev->dev);

 	return 0;
-- 
1.9.1
