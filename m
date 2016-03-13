From: isdn@linux-pingi.de
Subject: Re: [PATCH 2/2] mISDN: Support DR6 indication in mISDNipac driver
Date: Sun, 13 Mar 2016 04:13:51 +0100
Message-ID: <56E4DAEF.80100@linux-pingi.de>
References: <56E4A3EB.4050507@maciej.szmigiero.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:59305 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753912AbcCMDOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 22:14:05 -0500
In-Reply-To: <56E4A3EB.4050507@maciej.szmigiero.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Karsten Keil <keil@b1-systems.de>
Am 13.03.2016 um 00:19 schrieb Maciej S. Szmigiero:
> According to figure 39 in PEB3086 data sheet, version 1.4 this indication
> replaces DR when layer 1 transition source state is F6.
> 
> This fixes mISDN layer 1 getting stuck in F6 state in TE mode on
> Dialogic Diva 2.02 card (and possibly others) when NT deactivates it.
> 
> Signed-off-by: Maciej S. Szmigiero <mail@maciej.szmigiero.name>
> ---
>  drivers/isdn/hardware/mISDN/ipac.h      | 1 +
>  drivers/isdn/hardware/mISDN/mISDNipac.c | 2 ++
>  2 files changed, 3 insertions(+)
> 
> diff --git a/drivers/isdn/hardware/mISDN/ipac.h b/drivers/isdn/hardware/mISDN/ipac.h
> index 76aa6f8f298e..720ee72aab6a 100644
> --- a/drivers/isdn/hardware/mISDN/ipac.h
> +++ b/drivers/isdn/hardware/mISDN/ipac.h
> @@ -217,6 +217,7 @@ struct ipac_hw {
>  #define ISAC_IND_SD		0x2
>  #define ISAC_IND_DIS		0x3
>  #define ISAC_IND_RSY		0x4
> +#define ISAC_IND_DR6		0x5
>  #define ISAC_IND_EI		0x6
>  #define ISAC_IND_PU		0x7
>  #define ISAC_IND_ARD		0x8
> diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
> index cb428b9ee441..aa9b6c3cadc1 100644
> --- a/drivers/isdn/hardware/mISDN/mISDNipac.c
> +++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
> @@ -80,6 +80,7 @@ isac_ph_state_bh(struct dchannel *dch)
>  		l1_event(dch->l1, HW_DEACT_CNF);
>  		break;
>  	case ISAC_IND_DR:
> +	case ISAC_IND_DR6:
>  		dch->state = 3;
>  		l1_event(dch->l1, HW_DEACT_IND);
>  		break;
> @@ -660,6 +661,7 @@ isac_l1cmd(struct dchannel *dch, u32 cmd)
>  		spin_lock_irqsave(isac->hwlock, flags);
>  		if ((isac->state == ISAC_IND_EI) ||
>  		    (isac->state == ISAC_IND_DR) ||
> +		    (isac->state == ISAC_IND_DR6) ||
>  		    (isac->state == ISAC_IND_RS))
>  			ph_command(isac, ISAC_CMD_TIM);
>  		else
> 
> 
