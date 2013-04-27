From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable call"
Date: Sat, 27 Apr 2013 20:43:58 +0800
Message-ID: <CAHrpEqTE-oGcdMVk2LMffW0JWNgJ-b_+RakpCOVBy6WxA_ARGg@mail.gmail.com>
References: <1366966330-5181-1-git-send-email-l.stach@pengutronix.de>
	<CAHrpEqQLkjCOq0doaM0zNMkgjNkE_pOLxjoFJWNPuQ6CRHCbBw@mail.gmail.com>
	<20130426134415.GS1366@pengutronix.de>
	<20130426.143309.1011152996477262852.davem@davemloft.net>
	<20130427090545.GY1366@pengutronix.de>
	<CAHrpEqSi+caO5gSo1BZRGqytxhCOs-OuyjiCaG+7fnsnFBj77g@mail.gmail.com>
	<20130427120619.GA26097@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:52424 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591Ab3D0MoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 08:44:00 -0400
Received: by mail-wg0-f46.google.com with SMTP id e11so2596398wgh.25
        for <netdev@vger.kernel.org>; Sat, 27 Apr 2013 05:43:58 -0700 (PDT)
In-Reply-To: <20130427120619.GA26097@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/4/27, Francois Romieu <romieu@fr.zoreil.com>:
> Frank Li <lznuaa@gmail.com> :
> [...]
>> diff --git a/drivers/net/ethernet/freescale/fec.c
>> b/drivers/net/ethernet/freescale/fe
>> index 73195f6..c945bb7 100644
>> --- a/drivers/net/ethernet/freescale/fec.c
>> +++ b/drivers/net/ethernet/freescale/fec.c
>> @@ -403,6 +403,11 @@ fec_restart(struct net_device *ndev, int duplex)
>>         const struct platform_device_id *id_entry =
>>                                 platform_get_device_id(fep->pdev);
>>         int i;
>> +       if (netif_running(ndev)) {
>> +               napi_disable(&fep->napi);
>
> napi_disable may sleep.
>
> fec_restart can be called with spinlock held in fec_enet_adjust_link

You are right. Spin lock in FEC enet adjust link can be removed when
remove spinlock in tx and RX.

>
> --
> Ueimor
>
