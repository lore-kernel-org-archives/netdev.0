From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH 1/3] device: bus_type: Introduce num_vf callback
Date: Wed, 18 Jan 2017 14:04:37 +0100
Message-ID: <20170118130439.15023-2-phil@nwl.cc>
References: <20170118130439.15023-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33849 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754299AbdARNCI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 08:02:08 -0500
In-Reply-To: <20170118130439.15023-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows for bus types to implement their own method of retrieving
the number of virtual functions a NIC on that type of bus supports.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/linux/device.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/device.h b/include/linux/device.h
index 491b4c0ca6333..6d73b70a4a5d7 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -88,6 +88,8 @@ extern void bus_remove_file(struct bus_type *, struct bus_attribute *);
  *
  * @suspend:	Called when a device on this bus wants to go to sleep mode.
  * @resume:	Called to bring a device on this bus out of sleep mode.
+ * @num_vf:	Called to find out how many virtual functions a device on this
+ *		bus supports.
  * @pm:		Power management operations of this bus, callback the specific
  *		device driver's pm-ops.
  * @iommu_ops:  IOMMU specific operations for this bus, used to attach IOMMU
@@ -127,6 +129,8 @@ struct bus_type {
 	int (*suspend)(struct device *dev, pm_message_t state);
 	int (*resume)(struct device *dev);
 
+	int (*num_vf)(struct device *dev);
+
 	const struct dev_pm_ops *pm;
 
 	const struct iommu_ops *iommu_ops;
-- 
2.11.0
