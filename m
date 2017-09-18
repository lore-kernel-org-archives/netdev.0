From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH 10/16] thunderbolt: Move ring descriptor flags to thunderbolt.h
Date: Mon, 18 Sep 2017 18:30:43 +0300
Message-ID: <20170918153049.44185-11-mika.westerberg@linux.intel.com>
References: <20170918153049.44185-1-mika.westerberg@linux.intel.com>
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mario.Limonciello@dell.com, Lukas Wunner <lukas@wunner.de>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170918153049.44185-1-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A Thunderbolt service driver might need to check if there was an error
with the descriptor when in frame mode. We also add two Rx specific
error flags RING_DESC_CRC_ERROR and RING_DESC_BUFFER_OVERRUN.

Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
Reviewed-by: Michael Jamet <michael.jamet@intel.com>
Reviewed-by: Yehezkel Bernat <yehezkel.bernat@intel.com>
---
 drivers/thunderbolt/nhi_regs.h |  7 -------
 include/linux/thunderbolt.h    | 18 ++++++++++++++++++
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/thunderbolt/nhi_regs.h b/drivers/thunderbolt/nhi_regs.h
index 491a4c0c18fc..5ed6934e31e7 100644
--- a/drivers/thunderbolt/nhi_regs.h
+++ b/drivers/thunderbolt/nhi_regs.h
@@ -17,13 +17,6 @@ enum ring_flags {
 	RING_FLAG_ENABLE = 1 << 31,
 };
 
-enum ring_desc_flags {
-	RING_DESC_ISOCH = 0x1, /* TX only? */
-	RING_DESC_COMPLETED = 0x2, /* set by NHI */
-	RING_DESC_POSTED = 0x4, /* always set this */
-	RING_DESC_INTERRUPT = 0x8, /* request an interrupt on completion */
-};
-
 /**
  * struct ring_desc - TX/RX ring entry
  *
diff --git a/include/linux/thunderbolt.h b/include/linux/thunderbolt.h
index 1a376374c327..fac4ff62c0de 100644
--- a/include/linux/thunderbolt.h
+++ b/include/linux/thunderbolt.h
@@ -479,6 +479,24 @@ struct ring_frame;
 typedef void (*ring_cb)(struct tb_ring *, struct ring_frame *, bool canceled);
 
 /**
+ * enum ring_desc_flags - Flags for DMA ring descriptor
+ * %RING_DESC_ISOCH: Enable isonchronous DMA (Tx only)
+ * %RING_DESC_CRC_ERROR: In frame mode CRC check failed for the frame (Rx only)
+ * %RING_DESC_COMPLETED: Descriptor completed (set by NHI)
+ * %RING_DESC_POSTED: Always set this
+ * %RING_DESC_BUFFER_OVERRUN: RX buffer overrun
+ * %RING_DESC_INTERRUPT: Request an interrupt on compltion
+ */
+enum ring_desc_flags {
+	RING_DESC_ISOCH = 0x1,
+	RING_DESC_CRC_ERROR = 0x1,
+	RING_DESC_COMPLETED = 0x2,
+	RING_DESC_POSTED = 0x4,
+	RING_DESC_BUFFER_OVERRUN = 0x04,
+	RING_DESC_INTERRUPT = 0x8,
+};
+
+/**
  * struct ring_frame - For use with ring_rx/ring_tx
  * @buffer_phy: DMA mapped address of the frame
  * @callback: Callback called when the frame is finished
-- 
2.13.5
