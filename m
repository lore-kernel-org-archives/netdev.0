From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Mon, 8 Sep 2003 20:14:57 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309081953510.1261-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ricardoz@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Change the default number of Tx descriptors from 256 to 1024.
  Data from [ricardoz@us.ibm.com] shows it's easy to overrun
  the Tx desc queue.

-------------

diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_param.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_param.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_param.c	2003-08-22 16:57:59.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_param.c	2003-09-08 09:13:12.000000000 -0700
@@ -63,9 +63,10 @@ MODULE_PARM_DESC(X, S);
 /* Transmit Descriptor Count
  *
  * Valid Range: 80-256 for 82542 and 82543 gigabit ethernet controllers
- * Valid Range: 80-4096 for 82544
+ * Valid Range: 80-4096 for 82544 and newer
  *
- * Default Value: 256
+ * Default Value: 256 for 82542 and 82543 gigabit ethernet controllers
+ * Default Value: 1024 for 82544 and newer
  */
 
 E1000_PARAM(TxDescriptors, "Number of transmit descriptors");
@@ -73,7 +74,7 @@ E1000_PARAM(TxDescriptors, "Number of tr
 /* Receive Descriptor Count
  *
  * Valid Range: 80-256 for 82542 and 82543 gigabit ethernet controllers
- * Valid Range: 80-4096 for 82544
+ * Valid Range: 80-4096 for 82544 and newer
  *
  * Default Value: 256
  */
@@ -200,6 +201,7 @@ E1000_PARAM(InterruptThrottleRate, "Inte
 #define MAX_TXD                      256
 #define MIN_TXD                       80
 #define MAX_82544_TXD               4096
+#define DEFAULT_82544_TXD           1024
 
 #define DEFAULT_RXD                  256
 #define MAX_RXD                      256
@@ -320,12 +322,15 @@ e1000_check_options(struct e1000_adapter
 		struct e1000_option opt = {
 			.type = range_option,
 			.name = "Transmit Descriptors",
-			.err  = "using default of " __MODULE_STRING(DEFAULT_TXD),
-			.def  = DEFAULT_TXD,
 			.arg  = { .r = { .min = MIN_TXD }}
 		};
 		struct e1000_desc_ring *tx_ring = &adapter->tx_ring;
 		e1000_mac_type mac_type = adapter->hw.mac_type;
+		opt.err = mac_type < e1000_82544 ?
+			"using default of " __MODULE_STRING(DEFAULT_TXD) :
+			"using default of " __MODULE_STRING(DEFAULT_82544_TXD);
+		opt.def = mac_type < e1000_82544 ?
+			DEFAULT_TXD : DEFAULT_82544_TXD;
 		opt.arg.r.max = mac_type < e1000_82544 ?
 			MAX_TXD : MAX_82544_TXD;
 
