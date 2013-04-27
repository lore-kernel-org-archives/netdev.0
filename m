From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable
 call"
Date: Sat, 27 Apr 2013 14:06:19 +0200
Message-ID: <20130427120619.GA26097@electric-eye.fr.zoreil.com>
References: <1366966330-5181-1-git-send-email-l.stach@pengutronix.de>
 <CAHrpEqQLkjCOq0doaM0zNMkgjNkE_pOLxjoFJWNPuQ6CRHCbBw@mail.gmail.com>
 <20130426134415.GS1366@pengutronix.de>
 <20130426.143309.1011152996477262852.davem@davemloft.net>
 <20130427090545.GY1366@pengutronix.de>
 <CAHrpEqSi+caO5gSo1BZRGqytxhCOs-OuyjiCaG+7fnsnFBj77g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48407 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618Ab3D0MGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 08:06:32 -0400
Content-Disposition: inline
In-Reply-To: <CAHrpEqSi+caO5gSo1BZRGqytxhCOs-OuyjiCaG+7fnsnFBj77g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank Li <lznuaa@gmail.com> :
[...]
> diff --git a/drivers/net/ethernet/freescale/fec.c
> b/drivers/net/ethernet/freescale/fe
> index 73195f6..c945bb7 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -403,6 +403,11 @@ fec_restart(struct net_device *ndev, int duplex)
>         const struct platform_device_id *id_entry =
>                                 platform_get_device_id(fep->pdev);
>         int i;
> +       if (netif_running(ndev)) {
> +               napi_disable(&fep->napi);

napi_disable may sleep.

fec_restart can be called with spinlock held in fec_enet_adjust_link

-- 
Ueimor
