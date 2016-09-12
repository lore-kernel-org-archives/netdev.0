From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 08/15] ixgbe: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 10:03:39 -0400
Message-ID: <1473689026-6983-9-git-send-email-javier@osg.samsung.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 33c025055011..b06e32d0d22a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -45,10 +45,10 @@
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
 #include "ixgbe_dcb.h"
-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+#if IS_ENABLED(CONFIG_FCOE)
 #define IXGBE_FCOE
 #include "ixgbe_fcoe.h"
-#endif /* CONFIG_FCOE or CONFIG_FCOE_MODULE */
+#endif /* IS_ENABLED(CONFIG_FCOE) */
 #ifdef CONFIG_IXGBE_DCA
 #include <linux/dca.h>
 #endif
-- 
2.7.4
