From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH 2/3] PCI: implement num_vf bus type callback
Date: Wed, 18 Jan 2017 14:04:38 +0100
Message-ID: <20170118130439.15023-3-phil@nwl.cc>
References: <20170118130439.15023-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170118130439.15023-1-phil@nwl.cc>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 drivers/pci/pci-driver.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
index 1ccce1cd6aca4..63d8e18fb6b14 100644
--- a/drivers/pci/pci-driver.c
+++ b/drivers/pci/pci-driver.c
@@ -1432,6 +1432,11 @@ static int pci_uevent(struct device *dev, struct kobj_uevent_env *env)
 	return 0;
 }
 
+static int pci_bus_num_vf(struct device *dev)
+{
+	return pci_num_vf(to_pci_dev(dev));
+}
+
 struct bus_type pci_bus_type = {
 	.name		= "pci",
 	.match		= pci_bus_match,
@@ -1443,6 +1448,7 @@ struct bus_type pci_bus_type = {
 	.bus_groups	= pci_bus_groups,
 	.drv_groups	= pci_drv_groups,
 	.pm		= PCI_PM_OPS_PTR,
+	.num_vf		= pci_bus_num_vf,
 };
 EXPORT_SYMBOL(pci_bus_type);
 
-- 
2.11.0
