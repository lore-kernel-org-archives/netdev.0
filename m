From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] Allow building iwl3945 without iwl4965.
Date: Tue, 29 Apr 2008 10:19:57 +0800
Message-ID: <1209435597.2624.35.camel@debian.sh.intel.com>
References: <87zlrgl09s.fsf@sparse.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jason Riedy <jason@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:31731 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751411AbYD2CUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 22:20:46 -0400
In-Reply-To: <87zlrgl09s.fsf@sparse.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-04-26 at 15:27 -0700, Jason Riedy wrote:
> If IWL3945 ever depends on IWLCORE, the silent, user-invisible
> IWLWIFI option can go away.
> 
> Signed-off-by: Jason Riedy <jason@acm.org>
> ---
>    The breakage made it to Linus's tree but isn't in the wireless forest
>    (as far as I can see).  Commit 49186b4a083655 is a "part 2" without
>    a "part 1", so perhaps that "part 1" avoided the problem?
> 
>  drivers/net/wireless/Makefile        |    2 +-
>  drivers/net/wireless/iwlwifi/Kconfig |    6 ++++++
>  2 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
> index c2642bc..2c343aa 100644
> --- a/drivers/net/wireless/Makefile
> +++ b/drivers/net/wireless/Makefile
> @@ -56,7 +56,7 @@ obj-$(CONFIG_RTL8187)	+= rtl8187.o
>  
>  obj-$(CONFIG_ADM8211)	+= adm8211.o
>  
> -obj-$(CONFIG_IWLCORE)	+= iwlwifi/
> +obj-$(CONFIG_IWLWIFI)	+= iwlwifi/
>  obj-$(CONFIG_RT2X00)	+= rt2x00/
>  
>  obj-$(CONFIG_P54_COMMON)	+= p54/
> diff --git a/drivers/net/wireless/iwlwifi/Kconfig b/drivers/net/wireless/iwlwifi/Kconfig
> index c4e631d..9a25f55 100644
> --- a/drivers/net/wireless/iwlwifi/Kconfig
> +++ b/drivers/net/wireless/iwlwifi/Kconfig
> @@ -1,6 +1,11 @@
> +config IWLWIFI
> +	bool
> +	default n
> +
>  config IWLCORE
>  	tristate "Intel Wireless Wifi Core"
>  	depends on PCI && MAC80211 && WLAN_80211 && EXPERIMENTAL
> +	select IWLWIFI
>  
>  config IWLWIFI_LEDS
>  	bool
> @@ -106,6 +111,7 @@ config IWL3945
>  	tristate "Intel PRO/Wireless 3945ABG/BG Network Connection"
>  	depends on PCI && MAC80211 && WLAN_80211 && EXPERIMENTAL
>  	select FW_LOADER
> +	select IWLWIFI
>  	---help---
>  	  Select to build the driver supporting the:

Do we have a way to make "select IWLWIFI" generate CONFIG_IWLWIFI with
the same state as CONFIG_IWLCORE (or CONFIG_IWL3945)? AFAICS,
CONFIG_IWLWIFI is always 'y' whenever CONFIG_IWLCORE is 'y' or 'm'. If
the latter is 'm', the Makefile will generate a empty built-in.o which
requires vmlinux to update unnecessarily every time we only compile
iwl3945/4965 modules.

Thanks,
-yi

