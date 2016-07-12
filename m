From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: iwlwifi: add missing type declaration
Date: Tue, 12 Jul 2016 11:54:09 +0000 (UTC)
Message-ID: <20160712115409.7D7176127F@smtp.codeaurora.org>
References: <20160711205020.1587254-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes.berg@intel.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Luca Coelho <luciano.coelho@intel.com>,
	Intel Linux Wireless <linuxwifi@intel.com>,
	Eliad Peller <eliad@wizery.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160711205020.1587254-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:
> The iwl-debug.h header relies in implicit inclusion of linux/device.h and
> we get a lot of warnings without that:
> 
> drivers/net/wireless/intel/iwlwifi/iwl-debug.h:44:23: error: 'struct device' declared inside parameter list will not be visible outside of this definition or declaration [-Werror]
>  void __iwl_err(struct device *dev, bool rfkill_prefix, bool only_trace,
>                        ^~~~~~
> In file included from drivers/net/wireless/intel/iwlwifi/iwl-eeprom-read.h:66:0,
>                  from drivers/net/wireless/intel/iwlwifi/iwl-eeprom-read.c:68:
> drivers/net/wireless/intel/iwlwifi/iwl-trans.h: In function 'iwl_trans_tx':
> drivers/net/wireless/intel/iwlwifi/iwl-trans.h:1030:348: error: passing argument 1 of '__iwl_err' from incompatible pointer type [-Werror=incompatible-pointer-types]
>    IWL_ERR(trans, "%s bad state = %d\n", __func__, trans->state);
>                                                                                                                                                                                                                                                                                                                                                             ^
> In file included from drivers/net/wireless/intel/iwlwifi/iwl-eeprom-read.c:67:0:
> drivers/net/wireless/intel/iwlwifi/iwl-debug.h:44:6: note: expected 'struct device *' but argument is of type 'struct device *'
>  void __iwl_err(struct device *dev, bool rfkill_prefix, bool only_trace,
>       ^~~~~~~~~
> 
> The easiest workaround is to just declare 'struct device' before its first use,
> rather than including the entire header file.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 21cb3222fe56 ("iwlwifi: decouple PCIe transport from mac80211")
> Acked-by: Luca Coelho <luciano.coelho@intel.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

25f700ef0653 iwlwifi: add missing type declaration

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9224105/
