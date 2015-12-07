From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v3 net-next 2/4] net: dsa: cleanup resources upon module removal
Date: Mon,  7 Dec 2015 13:57:33 +0100
Message-ID: <1449493055-29047-3-git-send-email-narmstrong@baylibre.com>
References: <56321D9A.8010109@baylibre.com>
 <1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>
To: davem@davemloft.net, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	fabf@skynet.be, pavel.nakonechny@skitlab.ru, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure that we unassign the master_netdev dsa_ptr to make the packet
processing go through the regular Ethernet receive path.

Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 0f41f71..d9e0172 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -985,6 +985,14 @@ static int dsa_suspend(struct device *d)
 	struct dsa_switch_tree *dst = platform_get_drvdata(pdev);
 	int i, ret = 0;
 
+	dst->master_netdev->dsa_ptr = NULL;
+
+	/* If we used a tagging format that doesn't have an ethertype
+	 * field, make sure that all packets from this point get sent
+	 * without the tag and go through the regular receive path.
+	 */
+	wmb();
+
 	for (i = 0; i < dst->pd->nr_chips; i++) {
 		struct dsa_switch *ds = dst->ds[i];
 
-- 
1.9.1
