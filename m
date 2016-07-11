From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] iwlwifi: add missing type declaration
Date: Mon, 11 Jul 2016 22:49:53 +0200
Message-ID: <20160711205020.1587254-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Luca Coelho <luciano.coelho@intel.com>,
	Intel Linux Wireless <linuxwifi@intel.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Eliad Peller <eliad@wizery.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The iwl-debug.h header relies in implicit inclusion of linux/device.h and
we get a lot of warnings without that:

drivers/net/wireless/intel/iwlwifi/iwl-debug.h:44:23: error: 'struct device' declared inside parameter list will not be visible outside of this definition or declaration [-Werror]
 void __iwl_err(struct device *dev, bool rfkill_prefix, bool only_trace,
                       ^~~~~~
In file included from drivers/net/wireless/intel/iwlwifi/iwl-eeprom-read.h:66:0,
                 from drivers/net/wireless/intel/iwlwifi/iwl-eeprom-read.c:68:
drivers/net/wireless/intel/iwlwifi/iwl-trans.h: In function 'iwl_trans_tx':
drivers/net/wireless/intel/iwlwifi/iwl-trans.h:1030:348: error: passing argument 1 of '__iwl_err' from incompatible pointer type [-Werror=incompatible-pointer-types]
   IWL_ERR(trans, "%s bad state = %d\n", __func__, trans->state);
                                                                                                                                                                                                                                                                                                                                                            ^
In file included from drivers/net/wireless/intel/iwlwifi/iwl-eeprom-read.c:67:0:
drivers/net/wireless/intel/iwlwifi/iwl-debug.h:44:6: note: expected 'struct device *' but argument is of type 'struct device *'
 void __iwl_err(struct device *dev, bool rfkill_prefix, bool only_trace,
      ^~~~~~~~~

The easiest workaround is to just declare 'struct device' before its first use,
rather than including the entire header file.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 21cb3222fe56 ("iwlwifi: decouple PCIe transport from mac80211")
---
 drivers/net/wireless/intel/iwlwifi/iwl-debug.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/intel/iwlwifi/iwl-debug.h b/drivers/net/wireless/intel/iwlwifi/iwl-debug.h
index 110333208450..cd77c6971753 100644
--- a/drivers/net/wireless/intel/iwlwifi/iwl-debug.h
+++ b/drivers/net/wireless/intel/iwlwifi/iwl-debug.h
@@ -41,6 +41,7 @@ static inline bool iwl_have_debug_level(u32 level)
 #endif
 }
 
+struct device;
 void __iwl_err(struct device *dev, bool rfkill_prefix, bool only_trace,
 		const char *fmt, ...) __printf(4, 5);
 void __iwl_warn(struct device *dev, const char *fmt, ...) __printf(2, 3);
-- 
2.9.0
