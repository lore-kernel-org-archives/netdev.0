From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix random mdio_write failures
Date: Sat, 5 Jun 2010 14:41:03 +0200
Message-ID: <20100605124103.GA3213@electric-eye.fr.zoreil.com>
References: <4C0A1736.9030209@iki.fi>
 <1275733273-28321-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	Hayes <hayeswang@realtek.com>, davem@davemloft.net
To: Timo =?utf-8?B?VGVyw6Rz?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.185.140-88.rev.gaoland.net ([88.140.185.30]:57611 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S933259Ab0FEMle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 08:41:34 -0400
Content-Disposition: inline
In-Reply-To: <1275733273-28321-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=C3=A4s <timo.teras@iki.fi> :
[...]
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 217e709..03a8318 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -559,6 +559,11 @@ static void mdio_write(void __iomem *ioaddr, int=
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

--=20
Ueimor
