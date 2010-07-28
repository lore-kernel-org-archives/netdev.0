From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: RE: [net-next 1/3] stmmac: remove the STMMAC_DUAL_MAC option
Date: Wed, 28 Jul 2010 08:55:29 +0200
Message-ID: <107012446AC13D4C90B85672EAF5FB0E9C2E08DEE1@SAFEX1MAIL3.st.com>
References: <1280225387-26240-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:33208 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751118Ab0G1G4D convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jul 2010 02:56:03 -0400
In-Reply-To: <1280225387-26240-1-git-send-email-peppe.cavallaro@st.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Giuseppe CAVALLARO [mailto:peppe.cavallaro@st.com]
> Sent: Tuesday, July 27, 2010 12:10 PM
> To: netdev@vger.kernel.org
> Cc: Peppe CAVALLARO
> Subject: [net-next 1/3] stmmac: remove the STMMAC_DUAL_MAC option
> 
> The STMMAC_DUAL_MAC is now removed from the driver's Kconfig.
> It will be available from a specific STM boards Kconfig.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>


> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, July 28, 2010 5:45 AM
> To: Peppe CAVALLARO
> Cc: netdev@vger.kernel.org
> Subject: Re: [net-next 2/3] stmmac: fix timer setup when use dual mac
> Kconfig

[snip]
 
> This is not how we do things.
> 
> All of the options that influence the driver should be right next
> to the main driver option.
> 
> What the platform SOC Kconfig's can do is 'select' those option.
> 
> But even better is to get rid of all of these feature Kconfig options,
> and communicate the capability in the platform_device probe
> information or similar.

Hi David,

Indeed, this option doesn't impact the driver itself. Some STM SoCs
(7105,7106, 7108 ...) have two GMAC cores integrated in the same SoC.
So the meaning of this option was to turn-on the second device, only.
This option is also used within our board's setup files.
In the future, it could also generate some misunderstanding on other
platforms (ARM based) where there is no second GMAC device.
For this reason, I've removed it from the driver's Kconfig.

Welcome advice.

Thanks for the feedback.

Regards,
Peppe

> ---
>  drivers/net/stmmac/Kconfig |    9 ---------
>  1 files changed, 0 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/stmmac/Kconfig
> index eb63d44..2513555 100644
> --- a/drivers/net/stmmac/Kconfig
> +++ b/drivers/net/stmmac/Kconfig
> @@ -20,15 +20,6 @@ config STMMAC_DA
>  	  By default, the DMA arbitration scheme is based on Round-robin
>  	  (rx:tx priority is 1:1).
> 
> -config STMMAC_DUAL_MAC
> -	bool "STMMAC: dual mac support (EXPERIMENTAL)"
> -	default n
> -        depends on EXPERIMENTAL && STMMAC_ETH && !STMMAC_TIMER
> -	help
> -	  Some ST SoCs (for example the stx7141 and stx7200c2) have two
> -	  Ethernet Controllers. This option turns on the second Ethernet
> -	  device on this kind of platforms.
> -
>  config STMMAC_TIMER
>  	bool "STMMAC Timer optimisation"
>  	default n
> --
> 1.5.5.6

