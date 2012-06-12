From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH] iwlwifi: re-order module_init order to prevent NULL ptr deref
Date: Tue, 12 Jun 2012 21:13:32 +0200
Message-ID: <1339528412-4163-1-git-send-email-levinsasha928@gmail.com>
Cc: ilw@linux.intel.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <levinsasha928@gmail.com>
To: johannes.berg@intel.com, wey-yi.w.guy@intel.com,
	linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to make sure iwl_drv_init is called before iwl_init, since otherwise
iwl_init will NULL ptr deref when trying to add a new mode.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 drivers/net/wireless/iwlwifi/Makefile |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/Makefile b/drivers/net/wireless/iwlwifi/Makefile
index 98c8f64..16e39a4 100644
--- a/drivers/net/wireless/iwlwifi/Makefile
+++ b/drivers/net/wireless/iwlwifi/Makefile
@@ -1,5 +1,3 @@
-obj-$(CONFIG_IWLDVM)	+= dvm/
-
 CFLAGS_iwl-devtrace.o := -I$(src)
 
 # common
@@ -14,4 +12,6 @@ iwlwifi-objs		+= pcie/1000.o pcie/2000.o pcie/5000.o pcie/6000.o
 
 iwlwifi-$(CONFIG_IWLWIFI_DEVICE_TRACING) += iwl-devtrace.o
 
+obj-$(CONFIG_IWLDVM)    += dvm/
+
 ccflags-y += -D__CHECK_ENDIAN__ -I$(src)
-- 
1.7.8.6
