From: Magnus Damm <damm@opensource.se>
Subject: [PATCH] arlan: module parameter fixes
Date: Tue,  5 Apr 2005 20:05:50 +0200 (CEST)
Message-ID: <20050405173419.10402.34298.66044@clementine.local>
Cc: Magnus Damm <damm@opensource.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Make sure the code compiles with and without ARLAN_ENTRY_EXIT_DEBUGGING.
Only provide parameter descriptions when parameters are defined.
Remove "arlan_"-prefix to shape up built-in parameter names:

arlan.arlan_debug -> arlan.debug
arlan.arlan_EEPROM_bad -> arlan.EEPROM_bad
arlan.arlan_entry_and_exit_debug -> arlan.entry_and_exit_debug
arlan.arlan_entry_debug -> arlan.entry_debug
arlan.arlan_exit_debug -> arlan.exit_debug

Signed-off-by: Magnus Damm <damm@opensource.se>

--- linux-2.6.12-rc2/drivers/net/wireless/arlan-main.c	2005-04-05 16:57:26.000000000 +0200
+++ linux-2.6.12-rc2-autoparam/drivers/net/wireless/arlan-main.c	2005-04-05 19:21:54.223472976 +0200
@@ -33,8 +33,6 @@
 
 #ifdef ARLAN_DEBUGGING
 
-static int arlan_entry_debug;
-static int arlan_exit_debug;
 static int testMemory = testMemoryUNKNOWN;
 static int irq = irqUNKNOWN;
 static int txScrambled = 1;
@@ -43,15 +41,13 @@
 module_param(irq, int, 0);
 module_param(mdebug, int, 0);
 module_param(testMemory, int, 0);
-module_param(arlan_entry_debug, int, 0);
-module_param(arlan_exit_debug, int, 0);
 module_param(txScrambled, int, 0);
 MODULE_PARM_DESC(irq, "(unused)");
 MODULE_PARM_DESC(testMemory, "(unused)");
 MODULE_PARM_DESC(mdebug, "Arlan multicast debugging (0-1)");
 #endif
 
-module_param(arlan_debug, int, 0);
+module_param_named(debug, arlan_debug, int, 0);
 module_param(spreadingCode, int, 0);
 module_param(channelNumber, int, 0);
 module_param(channelSet, int, 0);
@@ -63,17 +59,19 @@
 module_param(tx_delay_ms, int, 0);
 module_param(retries, int, 0);
 module_param(tx_queue_len, int, 0);
-module_param(arlan_EEPROM_bad, int, 0);
-MODULE_PARM_DESC(arlan_debug, "Arlan debug enable (0-1)");
+module_param_named(EEPROM_bad, arlan_EEPROM_bad, int, 0);
+MODULE_PARM_DESC(debug, "Arlan debug enable (0-1)");
 MODULE_PARM_DESC(retries, "Arlan maximum packet retransmisions");
 #ifdef ARLAN_ENTRY_EXIT_DEBUGGING
-MODULE_PARM_DESC(arlan_entry_debug, "Arlan driver function entry debugging");
-MODULE_PARM_DESC(arlan_exit_debug, "Arlan driver function exit debugging");
-MODULE_PARM_DESC(arlan_entry_and_exit_debug, "Arlan driver function entry and exit debugging");
-#else
-MODULE_PARM_DESC(arlan_entry_debug, "(ignored)");
-MODULE_PARM_DESC(arlan_exit_debug, "(ignored)");
-MODULE_PARM_DESC(arlan_entry_and_exit_debug, "(ignored)");
+static int arlan_entry_debug;
+static int arlan_exit_debug;
+static int arlan_entry_and_exit_debug;
+module_param_named(entry_debug, arlan_entry_debug, int, 0);
+module_param_named(exit_debug, arlan_exit_debug, int, 0);
+module_param_named(entry_and_exit_debug, arlan_entry_and_exit_debug, int, 0);
+MODULE_PARM_DESC(entry_debug, "Arlan driver function entry debugging");
+MODULE_PARM_DESC(exit_debug, "Arlan driver function exit debugging");
+MODULE_PARM_DESC(entry_and_exit_debug, "Arlan driver function entry and exit debugging");
 #endif
 
 struct arlan_conf_stru arlan_conf[MAX_ARLANS];
