From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 23/25] wimax/i2400m: Move module params to other file so they can be static
Date: Fri, 14 May 2010 14:45:22 -0700
Message-ID: <9d7fdf1ba9d5b8963bf8ffe29eea17f508e81bde.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: Prasanna S Panchamukhi <prasannax.s.panchamukhi@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:45009 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932566Ab0ENVtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:21 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasanna S Panchamukhi <prasannax.s.panchamukhi@intel.com>

This patch moves the module parameters to the file where they
can be avoided to be global and allow them to be static.

The module param : idle_mode_disabled and power_save_disabled
are moved from  driver.c to control.c. Also these module parameters
are declared to be static as they are not required to be global anymore.
The module param : rx_reorder_disabled is moved from driver.c file to
rx.c file. Also this parameter is declated as static as it is not
required to be global anymore.

Signed-off-by: Prasanna S Panchamukhi<prasannax.s.panchamukhi@intel.com>
---
 drivers/net/wimax/i2400m/control.c |   15 +++++++++++++++
 drivers/net/wimax/i2400m/driver.c  |   19 -------------------
 drivers/net/wimax/i2400m/i2400m.h  |    6 ------
 drivers/net/wimax/i2400m/rx.c      |    5 +++++
 4 files changed, 20 insertions(+), 25 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index 6180772..0c1aa88 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -83,6 +83,21 @@
 #define D_SUBMODULE control
 #include "debug-levels.h"
 
+static int i2400m_idle_mode_disabled;/* 0 (idle mode enabled) by default */
+module_param_named(idle_mode_disabled, i2400m_idle_mode_disabled, int, 0644);
+MODULE_PARM_DESC(idle_mode_disabled,
+		 "If true, the device will not enable idle mode negotiation "
+		 "with the base station (when connected) to save power.");
+
+/* 0 (power saving enabled) by default */
+static int i2400m_power_save_disabled;
+module_param_named(power_save_disabled, i2400m_power_save_disabled, int, 0644);
+MODULE_PARM_DESC(power_save_disabled,
+		 "If true, the driver will not tell the device to enter "
+		 "power saving mode when it reports it is ready for it. "
+		 "False by default (so the device is told to do power "
+		 "saving).");
+
 int i2400m_passive_mode;	/* 0 (passive mode disabled) by default */
 module_param_named(passive_mode, i2400m_passive_mode, int, 0644);
 MODULE_PARM_DESC(passive_mode,
diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 39cf96a..66bdb5d 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -75,25 +75,6 @@
 #include "debug-levels.h"
 
 
-int i2400m_idle_mode_disabled;	/* 0 (idle mode enabled) by default */
-module_param_named(idle_mode_disabled, i2400m_idle_mode_disabled, int, 0644);
-MODULE_PARM_DESC(idle_mode_disabled,
-		 "If true, the device will not enable idle mode negotiation "
-		 "with the base station (when connected) to save power.");
-
-int i2400m_rx_reorder_disabled;	/* 0 (rx reorder enabled) by default */
-module_param_named(rx_reorder_disabled, i2400m_rx_reorder_disabled, int, 0644);
-MODULE_PARM_DESC(rx_reorder_disabled,
-		 "If true, RX reordering will be disabled.");
-
-int i2400m_power_save_disabled;	/* 0 (power saving enabled) by default */
-module_param_named(power_save_disabled, i2400m_power_save_disabled, int, 0644);
-MODULE_PARM_DESC(power_save_disabled,
-		 "If true, the driver will not tell the device to enter "
-		 "power saving mode when it reports it is ready for it. "
-		 "False by default (so the device is told to do power "
-		 "saving).");
-
 static char i2400m_debug_params[128];
 module_param_string(debug, i2400m_debug_params, sizeof(i2400m_debug_params),
 		    0644);
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 1babc55..fa74777 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -885,7 +885,6 @@ extern int i2400m_rx(struct i2400m *, struct sk_buff *);
 extern struct i2400m_msg_hdr *i2400m_tx_msg_get(struct i2400m *, size_t *);
 extern void i2400m_tx_msg_sent(struct i2400m *);
 
-extern int i2400m_power_save_disabled;
 
 /*
  * Utility functions
@@ -992,10 +991,5 @@ extern int i2400m_barker_db_init(const char *);
 extern void i2400m_barker_db_exit(void);
 
 
-/* Module parameters */
-
-extern int i2400m_idle_mode_disabled;
-extern int i2400m_rx_reorder_disabled;
-
 
 #endif /* #ifndef __I2400M_H__ */
diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index 0004c68..c835ae8 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -155,6 +155,11 @@
 #define D_SUBMODULE rx
 #include "debug-levels.h"
 
+static int i2400m_rx_reorder_disabled;	/* 0 (rx reorder enabled) by default */
+module_param_named(rx_reorder_disabled, i2400m_rx_reorder_disabled, int, 0644);
+MODULE_PARM_DESC(rx_reorder_disabled,
+		 "If true, RX reordering will be disabled.");
+
 struct i2400m_report_hook_args {
 	struct sk_buff *skb_rx;
 	const struct i2400m_l3l4_hdr *l3l4_hdr;
-- 
1.6.6.1

