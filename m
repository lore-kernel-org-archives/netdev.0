From: "Gridish Shlomi-RM96313" <gridish@freescale.com>
Subject: RE: [PATCH] [net, 83xx] ucc_geth.c: Fix upsmr setting in RMII mode
Date: Tue, 21 Apr 2009 14:22:42 +0300
Message-ID: <75B28D1B75754E4BAEAF634C9498EC900376A911@zil05exm11.fsl.freescale.net>
References: <49ED859B.30904@denx.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Kumar Gala" <galak@kernel.crashing.org>, <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>
To: <hs@denx.de>, "Li Yang-R58472" <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:60755 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752636AbZDULXD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 07:23:03 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n3LBMjbv007790
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 04:22:48 -0700 (MST)
Received: from zil05exm11.fsl.freescale.net (zil05exm11.ea.freescale.net [216.3.95.201])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n3LBMi5v006009
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 06:22:45 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <49ED859B.30904@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is correct.
Thanks
 

> -----Original Message-----
> From: Heiko Schocher [mailto:hs@denx.de] 
> Sent: Tuesday, April 21, 2009 11:37 AM
> To: Li Yang-R58472
> Cc: Gridish Shlomi-RM96313; Kumar Gala; 
> netdev@vger.kernel.org; linuxppc-dev@ozlabs.org
> Subject: [PATCH] [net, 83xx] ucc_geth.c: Fix upsmr setting in 
> RMII mode
> 
> If using the UCC on a MPC8360 in RMII mode, don;t set 
> UCC_GETH_UPSMR_RPM bit in the upsmr register.
> 
> Signed-off-by: Heiko Schocher <hs@denx.de>
> ---
>  drivers/net/ucc_geth.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c 
> index d3f39e8..44f8392 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -1394,7 +1394,8 @@ static int adjust_enet_interface(struct 
> ucc_geth_private *ugeth)
>  	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
>  	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID) ||
>  	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
> -		upsmr |= UCC_GETH_UPSMR_RPM;
> +		if (ugeth->phy_interface != PHY_INTERFACE_MODE_RMII)
> +			upsmr |= UCC_GETH_UPSMR_RPM;
>  		switch (ugeth->max_speed) {
>  		case SPEED_10:
>  			upsmr |= UCC_GETH_UPSMR_R10M;
> --
> 1.6.0.6
> 
> -- 
> DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
> HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
> 
