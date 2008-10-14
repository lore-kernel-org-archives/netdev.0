From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [build bug] CONFIG_MAC80211=m && CONFIG_RT2X00=y
Date: Tue, 14 Oct 2008 10:18:10 +0200
Message-ID: <200810141018.10856.IvDoorn@gmail.com>
References: <20081013074040.GA28840@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:33022 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbYJNISR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 04:18:17 -0400
Received: by ug-out-1314.google.com with SMTP id k3so826702ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 01:18:15 -0700 (PDT)
In-Reply-To: <20081013074040.GA28840@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> FYI, i triggered a build failure and have the hack below in -tip. Did 
> not have time to track down why the build fails exactly, so i disabled 
> the driver as a quick hack. Would be glad to test any fix patch.

This could perhaps have been caused by the change to menuconfig,

> diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wireless/rt2x00/Kconfig
> index f839ce0..8d02224 100644
> --- a/drivers/net/wireless/rt2x00/Kconfig
> +++ b/drivers/net/wireless/rt2x00/Kconfig
> @@ -1,6 +1,7 @@
>  menuconfig RT2X00
>  	bool "Ralink driver support"

Does changing bool to tristate help?
Because the depends are all properly set, so it should not be possible
to set rt2x00 to compiled-in while mac80211 is a module..

>  	depends on MAC80211 && WLAN_80211 && EXPERIMENTAL
> +	depends on BROKEN
>  	---help---
>  	  This will enable the experimental support for the Ralink drivers,
>  	  developed in the rt2x00 project <http://rt2x00.serialmonkey.com>.
> 

Ivo
