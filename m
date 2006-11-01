From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 14/18] e1000: reorder e1000_param.c
Date: Wed, 01 Nov 2006 09:52:01 -0800
Message-ID: <20061101175200.2356.73238.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:21520 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946975AbWKARoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:44:44 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This file needs some cleanups and reordering - logically order it
so that relevant defines and code are together with properly quoted
defaults.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_param.c |   78 ++++++++++-----------------------------
 1 files changed, 20 insertions(+), 58 deletions(-)

diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index 9c3c1ac..e4f8892 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -44,16 +44,6 @@
  */
 
 #define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] = OPTION_UNSET }
-/* Module Parameters are always initialized to -1, so that the driver
- * can tell the difference between no user specified value or the
- * user asking for the default value.
- * The true default values are loaded in when e1000_check_options is called.
- *
- * This is a GCC extension to ANSI C.
- * See the item "Labeled Elements in Initializers" in the section
- * "Extensions to the C Language Family" of the GCC documentation.
- */
-
 #define E1000_PARAM(X, desc) \
 	static int __devinitdata X[E1000_MAX_NIC+1] = E1000_PARAM_INIT; \
 	static int num_##X = 0; \
@@ -67,7 +57,6 @@
  *
  * Default Value: 256
  */
-
 E1000_PARAM(TxDescriptors, "Number of transmit descriptors");
 
 /* Receive Descriptor Count
@@ -77,7 +66,6 @@ E1000_PARAM(TxDescriptors, "Number of tr
  *
  * Default Value: 256
  */
-
 E1000_PARAM(RxDescriptors, "Number of receive descriptors");
 
 /* User Specified Speed Override
@@ -90,7 +78,6 @@ E1000_PARAM(RxDescriptors, "Number of re
  *
  * Default Value: 0
  */
-
 E1000_PARAM(Speed, "Speed setting");
 
 /* User Specified Duplex Override
@@ -102,7 +89,6 @@ E1000_PARAM(Speed, "Speed setting");
  *
  * Default Value: 0
  */
-
 E1000_PARAM(Duplex, "Duplex setting");
 
 /* Auto-negotiation Advertisement Override
@@ -119,8 +105,9 @@ E1000_PARAM(Duplex, "Duplex setting");
  *
  * Default Value: 0x2F (copper); 0x20 (fiber)
  */
-
 E1000_PARAM(AutoNeg, "Advertised auto-negotiation setting");
+#define AUTONEG_ADV_DEFAULT  0x2F
+#define AUTONEG_ADV_MASK     0x2F
 
 /* User Specified Flow Control Override
  *
@@ -132,8 +119,8 @@ E1000_PARAM(AutoNeg, "Advertised auto-ne
  *
  * Default Value: Read flow control settings from the EEPROM
  */
-
 E1000_PARAM(FlowControl, "Flow Control setting");
+#define FLOW_CONTROL_DEFAULT FLOW_CONTROL_FULL
 
 /* XsumRX - Receive Checksum Offload Enable/Disable
  *
@@ -144,53 +131,54 @@ E1000_PARAM(FlowControl, "Flow Control s
  *
  * Default Value: 1
  */
-
 E1000_PARAM(XsumRX, "Disable or enable Receive Checksum offload");
 
 /* Transmit Interrupt Delay in units of 1.024 microseconds
+ *  Tx interrupt delay needs to typically be set to something non zero
  *
  * Valid Range: 0-65535
- *
- * Default Value: 64
  */
-
 E1000_PARAM(TxIntDelay, "Transmit Interrupt Delay");
+#define DEFAULT_TIDV                  64
+#define MAX_TXDELAY               0xFFFF
+#define MIN_TXDELAY                    0
 
 /* Transmit Absolute Interrupt Delay in units of 1.024 microseconds
  *
  * Valid Range: 0-65535
- *
- * Default Value: 0
  */
-
 E1000_PARAM(TxAbsIntDelay, "Transmit Absolute Interrupt Delay");
+#define DEFAULT_TADV                  64
+#define MAX_TXABSDELAY            0xFFFF
+#define MIN_TXABSDELAY                 0
 
 /* Receive Interrupt Delay in units of 1.024 microseconds
+ *   hardware will likely hang if you set this to anything but zero.
  *
  * Valid Range: 0-65535
- *
- * Default Value: 0
  */
-
 E1000_PARAM(RxIntDelay, "Receive Interrupt Delay");
+#define DEFAULT_RDTR                   0
+#define MAX_RXDELAY               0xFFFF
+#define MIN_RXDELAY                    0
 
 /* Receive Absolute Interrupt Delay in units of 1.024 microseconds
  *
  * Valid Range: 0-65535
- *
- * Default Value: 128
  */
-
 E1000_PARAM(RxAbsIntDelay, "Receive Absolute Interrupt Delay");
+#define DEFAULT_RADV                 128
+#define MAX_RXABSDELAY            0xFFFF
+#define MIN_RXABSDELAY                 0
 
 /* Interrupt Throttle Rate (interrupts/sec)
  *
  * Valid Range: 100-100000 (0=off, 1=dynamic)
- *
- * Default Value: 8000
  */
-
 E1000_PARAM(InterruptThrottleRate, "Interrupt Throttling Rate");
+#define DEFAULT_ITR                 8000
+#define MAX_ITR                   100000
+#define MIN_ITR                      100
 
 /* Enable Smart Power Down of the PHY
  *
@@ -198,7 +186,6 @@ E1000_PARAM(InterruptThrottleRate, "Inte
  *
  * Default Value: 0 (disabled)
  */
-
 E1000_PARAM(SmartPowerDownEnable, "Enable PHY smart power down");
 
 /* Enable Kumeran Lock Loss workaround
@@ -207,33 +194,8 @@ E1000_PARAM(SmartPowerDownEnable, "Enabl
  *
  * Default Value: 1 (enabled)
  */
-
 E1000_PARAM(KumeranLockLoss, "Enable Kumeran lock loss workaround");
 
-#define AUTONEG_ADV_DEFAULT  0x2F
-#define AUTONEG_ADV_MASK     0x2F
-#define FLOW_CONTROL_DEFAULT FLOW_CONTROL_FULL
-
-#define DEFAULT_RDTR                   0
-#define MAX_RXDELAY               0xFFFF
-#define MIN_RXDELAY                    0
-
-#define DEFAULT_RADV                 128
-#define MAX_RXABSDELAY            0xFFFF
-#define MIN_RXABSDELAY                 0
-
-#define DEFAULT_TIDV                  64
-#define MAX_TXDELAY               0xFFFF
-#define MIN_TXDELAY                    0
-
-#define DEFAULT_TADV                  64
-#define MAX_TXABSDELAY            0xFFFF
-#define MIN_TXABSDELAY                 0
-
-#define DEFAULT_ITR                 8000
-#define MAX_ITR                   100000
-#define MIN_ITR                      100
-
 struct e1000_option {
 	enum { enable_option, range_option, list_option } type;
 	char *name;



---
Auke Kok <auke-jan.h.kok@intel.com>
