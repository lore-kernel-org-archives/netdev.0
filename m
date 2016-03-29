From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: Re: [PATCH 06/16] wcn36xx: Fetch private sta data from sta entry
 instead of from vif
Date: Tue, 29 Mar 2016 14:37:21 -0700
Message-ID: <20160329213721.GV8929@tuxbot>
References: <1459231593-360-7-git-send-email-bjorn.andersson@linaro.org>
 <201603300022.MmhimaU1%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pontus Fuchs <pontus.fuchs@gmail.com>, kbuild-all@01.org,
	wcn36xx@lists.infradead.org,
	Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201603300022.MmhimaU1%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue 29 Mar 10:01 PDT 2016, kbuild test robot wrote:

> Hi Pontus,
> 
> [auto build test ERROR on wireless-drivers/master]
> [also build test ERROR on v4.6-rc1 next-20160329]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Bjorn-Andersson/Misc-wcn36xx-fixes/20160329-141847
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git master
> config: sparc64-allyesconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=sparc64 
> 
> Note: the linux-review/Bjorn-Andersson/Misc-wcn36xx-fixes/20160329-141847 HEAD 8303daac889854237207e7caefaea94fee0b87f2 builds fine.
>       It only hurts bisectibility.
> 
> All error/warnings (new ones prefixed by >>):
> 
>    drivers/net/wireless/ath/wcn36xx/main.c: In function 'wcn36xx_set_key':
> >> drivers/net/wireless/ath/wcn36xx/main.c:389:9: error: implicit declaration of function 'wcn36xx_sta_to_priv' [-Werror=implicit-function-declaration]
>      struct wcn36xx_sta *sta_priv = wcn36xx_sta_to_priv(sta);
>             ^
> >> drivers/net/wireless/ath/wcn36xx/main.c:389:33: warning: initialization makes pointer from integer without a cast
>      struct wcn36xx_sta *sta_priv = wcn36xx_sta_to_priv(sta);
>                                     ^
>    cc1: some warnings being treated as errors

This should have been reordered with patch 7, that introduces this
helper function. Do you want me to resend, or can you apply the patches
out of order?

Regards,
Bjorn

> 
> vim +/wcn36xx_sta_to_priv +389 drivers/net/wireless/ath/wcn36xx/main.c
> 
>    383				   struct ieee80211_vif *vif,
>    384				   struct ieee80211_sta *sta,
>    385				   struct ieee80211_key_conf *key_conf)
>    386	{
>    387		struct wcn36xx *wcn = hw->priv;
>    388		struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
>  > 389		struct wcn36xx_sta *sta_priv = wcn36xx_sta_to_priv(sta);
>    390		int ret = 0;
>    391		u8 key[WLAN_MAX_KEY_LEN];
>    392	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation


> _______________________________________________
> wcn36xx mailing list
> wcn36xx@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/wcn36xx
