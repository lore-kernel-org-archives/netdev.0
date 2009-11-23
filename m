From: Gregory Haskins <ghaskins@novell.com>
Subject: [-next PATCH 4/4] vbus: fix pcibridge busmaster support
Date: Mon, 23 Nov 2009 14:54:49 -0500
Message-ID: <20091123195449.8184.18927.stgit@dev.haskins.net>
References: <20091123195136.8184.68042.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net
To: linux-next@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756691AbZKWTyv@vger.kernel.org>
In-Reply-To: <20091123195136.8184.68042.stgit@dev.haskins.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should technically enable the busmaster bit, even though its not
actually used on the host side

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 drivers/vbus/pci-bridge.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/vbus/pci-bridge.c b/drivers/vbus/pci-bridge.c
index ddc3f39..962ef58 100644
--- a/drivers/vbus/pci-bridge.c
+++ b/drivers/vbus/pci-bridge.c
@@ -932,6 +932,8 @@ vbus_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (ret < 0)
 		return ret;
 
+	pci_set_master(pdev);
+
 	ret = pci_request_regions(pdev, VBUS_PCI_NAME);
 	if (ret < 0) {
 		printk(KERN_ERR "VBUS_PCI: Could not init BARs: %d\n", ret);
