From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/5 03/12] wimax/i2400m: implement passive mode as a module option
Date: Wed,  4 Nov 2009 13:40:08 -0800
Message-ID: <55a662d6468005ec3cd799fbd8d0ad03dfae6d2a.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:28864 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932789AbZKDVmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:18 -0500
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some versions of the user space Intel WiMAX daemon need to have full
control over the device initialization sequence. By setting the module
option i2400.passive_mode to 1, the driver defers all device
configuration and initialization to user space.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/control.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index 8fe70e7..b69fd88 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -82,6 +82,13 @@
 #define D_SUBMODULE control
 #include "debug-levels.h"
 
+int i2400m_passive_mode;	/* 0 (passive mode disabled) by default */
+module_param_named(passive_mode, i2400m_passive_mode, int, 0644);
+MODULE_PARM_DESC(passive_mode,
+		 "If true, the driver will not do any device setup "
+		 "and leave it up to user space, who must be properly "
+		 "setup.");
+
 
 /*
  * Return if a TLV is of a give type and size
@@ -1335,6 +1342,8 @@ int i2400m_dev_initialize(struct i2400m *i2400m)
 	unsigned argc = 0;
 
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
+	if (i2400m_passive_mode)
+		goto out_passive;
 	/* Disable idle mode? (enabled by default) */
 	if (i2400m_idle_mode_disabled) {
 		if (i2400m_le_v1_3(i2400m)) {
@@ -1377,6 +1386,7 @@ int i2400m_dev_initialize(struct i2400m *i2400m)
 	result = i2400m_set_init_config(i2400m, args, argc);
 	if (result < 0)
 		goto error;
+out_passive:
 	/*
 	 * Update state: Here it just calls a get state; parsing the
 	 * result (System State TLV and RF Status TLV [done in the rx
-- 
1.6.2.5

