From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware
 restart.
Date: Sun, 21 Sep 2008 11:04:22 -0700
Message-ID: <20080921110422.1d010b96@infradead.org>
References: <20080921172316.GA6306@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ipw2100-devel@lists.sourceforge.net,
	linux-wireless@vger.kernel.org, yi.zhu@intel.com,
	reinette.chatre@intel.com, jgarzik@pobox.com,
	linville@tuxdriver.com, davem@davemloft.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752605AbYIUSEi@vger.kernel.org>
In-Reply-To: <20080921172316.GA6306@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 21 Sep 2008 21:23:17 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> Hi.
> 
> Following bug exists in the ipw2100 driver/firmware for years and
> Intel folks never responded to zillions bugzilla entries and forum
> notices in the internet with some patch or firmware update (although
> did request dmesg and debug info, and received them).
> 
> ipw2100: Fatal interrupt. Scheduling firmware restart.
> 
> I believe it is a firmware bug because after driver is unloaded and
> loaded back again wireless adapter usually starts working (for small
> amount of time though). 
\
> diff --git a/drivers/net/wireless/Kconfig
> b/drivers/net/wireless/Kconfig index 9931b5a..c24fc6a 100644
> --- a/drivers/net/wireless/Kconfig
> +++ b/drivers/net/wireless/Kconfig
> @@ -125,7 +125,7 @@ config PCMCIA_RAYCS
>  
>  config IPW2100
>  	tristate "Intel PRO/Wireless 2100 Network Connection"
> -	depends on PCI && WLAN_80211
> +	depends on PCI && WLAN_80211 && BROKEN
>  	select WIRELESS_EXT
>  	select FW_LOADER
>  	select IEEE80211
> 

so now you go from an occasional burp to having nothing at all.
How about you run with this patch on your own machine only?

or.. since you say a reload of the driver fixes it.. why don't you make
a patch for the driver that does basically the actions of a reload
automatically when the driver detects the issue?
(and stick a WARN_ON in for good measure so that kerneloops.org can
start tracking these burps)

-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
