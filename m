From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 21/21] wimax: fix gcc warnings in sh4 when calling BUG()
Date: Thu, 11 Jun 2009 14:35:58 -0700
Message-ID: <98eb0f53e2fc66482e2ea8033c58b20a079e5260.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28457 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756575AbZFKVgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:51 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH4's BUG() seems to confuse the compiler as it is considered to
return; thus, some functions would trigger usage of uninitialized
variables or non-void functions returning void.

Work around by initializing/returning.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/op-rfkill.c |    4 +++-
 drivers/net/wimax/i2400m/usb.c       |    4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/op-rfkill.c b/drivers/net/wimax/i2400m/op-rfkill.c
index 487ec58..43927b5 100644
--- a/drivers/net/wimax/i2400m/op-rfkill.c
+++ b/drivers/net/wimax/i2400m/op-rfkill.c
@@ -54,8 +54,10 @@ int i2400m_radio_is(struct i2400m *i2400m, enum wimax_rf_state state)
 		/* state == WIMAX_RF_ON */
 		return i2400m->state != I2400M_SS_RF_OFF
 			&& i2400m->state != I2400M_SS_RF_SHUTDOWN;
-	else
+	else {
 		BUG();
+		return -EINVAL;	/* shut gcc warnings on certain arches */
+	}
 }
 
 
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index ebc05da..cfdaf69 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -254,8 +254,10 @@ do_bus_reset:
 			dev_err(dev, "USB reset failed (%d), giving up!\n",
 				result);
 		}
-	} else
+	} else {
+		result = -EINVAL;	/* shut gcc up in certain arches */
 		BUG();
+	}
 	if (result < 0
 	    && result != -EINVAL	/* device is gone */
 	    && rt != I2400M_RT_BUS) {
-- 
1.6.2.3

