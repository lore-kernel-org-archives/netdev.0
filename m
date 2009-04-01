From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30] cxgb3: clear shadow BAR registers
Date: Tue, 31 Mar 2009 17:58:54 -0700
Message-ID: <20090401005854.15175.44595.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:32368 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbZDAA66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 20:58:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Ensure that internal shadow BAR registers are cleared on 32-bit platforms.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 2c2aaa7..3f22da4 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2984,6 +2984,20 @@ static void __devinit print_port_info(struct adapter *adap,
 	}
 }
 
+static void touch_bars(struct pci_dev *pdev)
+{
+#if BITS_PER_LONG < 64
+	u32 v;
+
+	pci_config_dword(pdev, PCI_BASE_ADDRESS_1, &v);
+	pci_write_config_dword(pdev, PCI_BASE_ADDRESS_1, v);
+	pci_read_config_dword(pdev, PCI_BASE_ADDRESS_3, &v);
+	pci_write_config_dword(pdev, PCI_BASE_ADDRESS_3, v);
+	pci_read_config_dword(pdev, PCI_BASE_ADDRESS_5, &v);
+	pci_write_config_dword(pdev, PCI_BASE_ADDRESS_5, v);
+#endif
+}
+
 static const struct net_device_ops cxgb_netdev_ops = {
 	.ndo_open		= cxgb_open,
 	.ndo_stop		= cxgb_close,
@@ -3051,6 +3065,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 		goto out_disable_device;
 	}
 
+	touch_bars(pdev);
 	pci_set_master(pdev);
 	pci_save_state(pdev);
 

