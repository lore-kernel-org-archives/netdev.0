From: Kiran Padwal <kiran.padwal@smartplayin.com>
Subject: [PATCH] ARCNET: Add missing error check for devm_kzalloc
Date: Thu,  5 Feb 2015 17:01:37 +0530
Message-ID: <1423135897-20448-1-git-send-email-kiran.padwal@smartplayin.com>
Cc: Michael Grzeschik <m.grzeschik@pengutronix.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kiran Padwal <kiran.padwal21@gmail.com>,
	Kiran Padwal <kiran.padwal@smartplayin.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch add a missing check on the return value of devm_kzalloc,
which would cause a NULL pointer dereference in a OOM situation.

Signed-off-by: Kiran Padwal <kiran.padwal@smartplayin.com>
---
 drivers/net/arcnet/com20020-pci.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 6c99ff0..945f532 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -78,6 +78,9 @@ static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *i
 
 	priv = devm_kzalloc(&pdev->dev, sizeof(struct com20020_priv),
 			    GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
 	ci = (struct com20020_pci_card_info *)id->driver_data;
 	priv->ci = ci;
 
-- 
1.7.9.5
