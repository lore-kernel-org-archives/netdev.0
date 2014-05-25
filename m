From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] wan: time_before()
Date: Sun, 25 May 2014 10:58:52 -0700
Message-ID: <1401040732.22191.8.camel@joe-AO725>
References: <1401039163-10727-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kevin.curtis@farsite.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Manuel =?ISO-8859-1?Q?Sch=F6lling?= <manuel.schoelling@gmx.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1401039163-10727-1-git-send-email-manuel.schoelling@gmx.de>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-05-25 at 19:32 +0200, Manuel Sch=F6lling wrote:
> To be future-proof and for better readability the time comparisons ar=
e
> modified to use time_before() instead of plain, error-prone math.

Sensible change, but it seems these should be
udelay(some_constant) instead of a a rather
variable time wait based on a system/config
defined jiffies.

Kevin?

> diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
[]
> @@ -697,14 +697,14 @@ fst_cpureset(struct fst_card_info *card)
>  		 * We are delaying here to allow the 9054 to reset itself
>  		 */
>  		j =3D jiffies + 1;
> -		while (jiffies < j)
> +		while (time_before(jiffies, j))
>  			/* Do nothing */ ;
>  		outw(0x240f, card->pci_conf + CNTRL_9054 + 2);
>  		/*
>  		 * We are delaying here to allow the 9054 to reload its eeprom
>  		 */
>  		j =3D jiffies + 1;
> -		while (jiffies < j)
> +		while (time_before(jiffies, j))
>  			/* Do nothing */ ;
>  		outw(0x040f, card->pci_conf + CNTRL_9054 + 2);
> =20



--
To unsubscribe from this list: send the line "unsubscribe kernel-janito=
rs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
