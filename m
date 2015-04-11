From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net/wireless: CFG80211_WEXT_EXPORT requires wireless
 extensions
Date: Sat, 11 Apr 2015 08:16:51 +0200
Message-ID: <1428733011.2139.1.camel@sipsolutions.net>
References: <2303996.H1mYPouv05@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35428 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546AbbDKGQ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Apr 2015 02:16:57 -0400
In-Reply-To: <2303996.H1mYPouv05@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-04-11 at 00:29 +0200, Arnd Bergmann wrote:
> The CFG80211_WEXT_EXPORT symbol is selected by two drivers that
> make direct use of compat handlers for the wireless ioctls.
> However, this has no effect when the wireless extensions themselves
> are disabled, and results in a link error:
> 
> ERROR: "cfg80211_wext_giwrts" [drivers/net/wireless/orinoco/orinoco.ko] undefined!
> ERROR: "cfg80211_wext_siwfrag" [drivers/net/wireless/orinoco/orinoco.ko] undefined!
> ERROR: "cfg80211_wext_giwname" [drivers/net/wireless/ipw2x00/ipw2200.ko] undefined!
> 
> This changes the Kconfig logic so that CFG80211_WEXT can not
> be disabled when CFG80211_WEXT_EXPORT is set.

> +++ b/net/wireless/Kconfig
> @@ -178,7 +178,6 @@ config CFG80211_WEXT
>  	bool "cfg80211 wireless extensions compatibility"

(I added "if !CFG80211_WEXT_EXPORT" to this line)

>  	depends on CFG80211
>  	select WEXT_CORE
> -	default y if CFG80211_WEXT_EXPORT
>  	help
>  	  Enable this option if you need old userspace for wireless
>  	  extensions with cfg80211-based drivers.
> @@ -186,6 +185,7 @@ config CFG80211_WEXT
>  config CFG80211_WEXT_EXPORT
>  	bool
>  	depends on CFG80211
> +	select CFG80211_WEXT

This doesn't work afaict because select won't go through if this is
selected. I've already sent a fix for this in my latest pull request
that has the above.

johannes
