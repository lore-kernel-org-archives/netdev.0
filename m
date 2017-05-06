From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] net: dsa: loop: Check for memory allocation failure
Date: Sat,  6 May 2017 07:29:45 +0200
Message-ID: <20170506052945.2639-1-christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If 'devm_kzalloc' fails, a NULL pointer will be dereferenced.
Return -ENOMEM instead, as done for some other memory allocation just a
few lines above.

Fixes: 98cd1552ea27 ("net: dsa: Mock-up driver")

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/dsa/dsa_loop.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index f0fc4de4fc9a..a19e1781e9bb 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -256,6 +256,9 @@ static int dsa_loop_drv_probe(struct mdio_device *mdiodev)
 		return -ENOMEM;
 
 	ps = devm_kzalloc(&mdiodev->dev, sizeof(*ps), GFP_KERNEL);
+	if (!ps)
+		return -ENOMEM;
+
 	ps->netdev = dev_get_by_name(&init_net, pdata->netdev);
 	if (!ps->netdev)
 		return -EPROBE_DEFER;
-- 
2.11.0
