From: Stas Sergeev <stsp@list.ru>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Mon, 14 Sep 2015 14:06:13 +0300
Message-ID: <55F6AA25.2070603@list.ru>
References: <20150914103207.GH21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp42.i.mail.ru ([94.100.177.102]:46643 "EHLO smtp42.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755166AbbINLGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2015 07:06:25 -0400
In-Reply-To: <20150914103207.GH21084@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

14.09.2015 13:32, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
> I've been bringing up the mainline kernel on a new board, which has
> an Marvell SoC with a mvneta interface connected to a Marvell DSA
> switch.  The DSA switch is a 88E6176.
>
> In the DT block for the interface, I specify:
>
> 	ethernet@... {
> 	        phy-mode =3D "sgmii";
> 		status =3D "okay";
>
> 		fixed-link {
> 			speed =3D <1000>;
> 			full-duplex;
> 		};
> 	};
>
> However, this doesn't work without patching mvneta to disable the
> autonegotiation and forcing the link up:
>
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethe=
rnet/marvell/mvneta.c
> index 62e48bc0cb23..e1698731e429 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -1010,6 +1010,10 @@ static void mvneta_defaults_set(struct mvneta_=
port *pp)
>   		val |=3D MVNETA_GMAC_INBAND_AN_ENABLE |
>   		       MVNETA_GMAC_AN_SPEED_EN |
>   		       MVNETA_GMAC_AN_DUPLEX_EN;
> +		/* We appear to need the interface forced for DSA switches */
> +		val &=3D ~(MVNETA_GMAC_AN_DUPLEX_EN |
> +			 MVNETA_GMAC_AN_SPEED_EN);
> +		val |=3D MVNETA_GMAC_FORCE_LINK_PASS;
>   		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
>   		val =3D mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
>   		val |=3D MVNETA_GMAC_1MS_CLOCK_ENABLE;
Hello Russell, just to make sure, aren't you missing this by any chance=
:
https://lkml.org/lkml/2015/7/20/710
