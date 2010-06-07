From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH] r8169: fix random mdio_write failures
Date: Mon, 7 Jun 2010 17:26:10 +0800
Message-ID: <4C31B2E3BE2B481DB749C669DFE23645@realtek.com.tw>
References: <4C0A1736.9030209@iki.fi>     <1275733273-28321-1-git-send-email-timo.teras@iki.fi> <20100605124103.GA3213@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: 'Francois Romieu' <romieu@fr.zoreil.com>,
	=?iso-8859-1?Q?'Timo_Ter=E4s'?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtitmf2.realtek.com.tw ([60.250.210.236]:3152 "EHLO
	mf2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305Ab0FGJbU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 05:31:20 -0400
In-Reply-To: <20100605124103.GA3213@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our hardware engineer suggests that check the completed indication
per 100 micro seconds. And it needs 20 micro seconds delay after the=20
completed indication for the next command.
=20
Best Regards,
Hayes


-----Original Message-----
=46rom: Francois Romieu [mailto:romieu@fr.zoreil.com]=20
Sent: Saturday, June 05, 2010 8:41 PM
To: Timo Ter=E4s
Cc: netdev@vger.kernel.org; Edward Hsu; Hayeswang; davem@davemloft.net
Subject: Re: [PATCH] r8169: fix random mdio_write failures

Timo Ter=E4s <timo.teras@iki.fi> :
[...]
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c index=20
> 217e709..03a8318 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -559,6 +559,11 @@ static void mdio_write(void __iomem *ioaddr, int
reg_addr, int value)
>  			break;
>  		udelay(25);
>  	}
> +	/*
> +	 * Some configurations require a small delay even after the write
> +	 * completed indication or the next write might fail.
> +	 */
> +	udelay(25);

Acked-off-by: Francois Romieu <romieu@fr.zoreil.com>

Good work.

I wonder if increasing the in-loop delay as well would help the write
succeed faster (or slower ?).

--
Ueimor


------Please consider the environment before printing this e-mail.=20



