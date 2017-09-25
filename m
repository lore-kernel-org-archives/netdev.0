From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH v2 14/16] thunderbolt: Add function to retrieve DMA device for the ring
Date: Mon, 25 Sep 2017 14:07:36 +0300
Message-ID: <20170925110738.68382-15-mika.westerberg@linux.intel.com>
References: <20170925110738.68382-1-mika.westerberg@linux.intel.com>
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mario.Limonciello@dell.com, Lukas Wunner <lukas@wunner.de>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170925110738.68382-1-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is needed when Thunderbolt service drivers need to DMA map memory
before it is passed down to the ring.

Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
Reviewed-by: Michael Jamet <michael.jamet@intel.com>
Reviewed-by: Yehezkel Bernat <yehezkel.bernat@intel.com>
---
 include/linux/thunderbolt.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/linux/thunderbolt.h b/include/linux/thunderbolt.h
index 36925e3aec7c..7b69853188b1 100644
--- a/include/linux/thunderbolt.h
+++ b/include/linux/thunderbolt.h
@@ -19,6 +19,7 @@
 #include <linux/list.h>
 #include <linux/mutex.h>
 #include <linux/mod_devicetable.h>
+#include <linux/pci.h>
 #include <linux/uuid.h>
 #include <linux/workqueue.h>
 
@@ -582,4 +583,16 @@ static inline int tb_ring_tx(struct tb_ring *ring, struct ring_frame *frame)
 struct ring_frame *tb_ring_poll(struct tb_ring *ring);
 void tb_ring_poll_complete(struct tb_ring *ring);
 
+/**
+ * tb_ring_dma_device() - Return device used for DMA mapping
+ * @ring: Ring whose DMA device is retrieved
+ *
+ * Use this function when you are mapping DMA for buffers that are
+ * passed to the ring for sending/receiving.
+ */
+static inline struct device *tb_ring_dma_device(struct tb_ring *ring)
+{
+	return &ring->nhi->pdev->dev;
+}
+
 #endif /* THUNDERBOLT_H_ */
-- 
2.14.1
