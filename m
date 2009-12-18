From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH v2 2/6] net: Add netif_num_vf function
Date: Thu, 17 Dec 2009 17:34:10 -0800
Message-ID: <20091218013410.4510.40263.stgit@localhost.localdomain>
References: <20091218013329.4510.25937.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:49622
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751075AbZLRBe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 20:34:27 -0500
In-Reply-To: <20091218013329.4510.25937.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Add a convenience function to determine how many VF devices are associated
with a given PF network interface. If the device is not an SR-IOV physical
function device, the function returns 0.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/netdevice.h |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a3fccc8..f6e521e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -38,6 +38,7 @@
 #include <asm/byteorder.h>
 
 #include <linux/device.h>
+#include <linux/pci.h>
 #include <linux/percpu.h>
 #include <linux/rculist.h>
 #include <linux/dmaengine.h>
@@ -1509,6 +1510,32 @@ static inline int netif_is_multiqueue(const struct net_device *dev)
 {
 	return (dev->num_tx_queues > 1);
 }
+/**
+ *	netif_num_vf - return number of SR-IOV VFs
+ *	@dev: network device
+ *
+ *	Return the number of SR-IOV virtual function devices that are
+ *	associated with this physical function device. Returns 0 if
+ *	device is not a PF device, or if SR-IOV not enabled.
+ */
+static inline int netif_num_vf(const struct net_device *dev)
+{
+	struct pci_dev *pdev;
+	int retval = 0;
+
+	if (!dev)
+		goto out;
+
+	if (!dev->dev.parent)
+		goto out;
+
+	if (dev->dev.parent->bus == &pci_bus_type) {
+		pdev = to_pci_dev(dev->dev.parent);
+		retval = pci_num_vf(pdev);
+	}
+out:
+	return retval;
+}
 
 /* Use this variant when it is known for sure that it
  * is executing from hardware interrupt context or with hardware interrupts

