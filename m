From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] drivers/net/wan/farsync.c: add missing iounmap
Date: Mon, 16 Apr 2012 17:22:12 +0200
Message-ID: <1334589732-25876-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kevin Curtis <kevin.curtis@farsite.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Free card->mem in the error-handling code since it was successfully
allocated just above.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wan/farsync.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index ebb9f24..1a62318 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2483,6 +2483,7 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		pr_err("Control memory remap failed\n");
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
+		iounmap(card->mem);
 		kfree(card);
 		return -ENODEV;
 	}
