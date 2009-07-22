From: Chris Zankel <chris@zankel.net>
Subject: Re: [PATCH] move xtsonic's probe function to .devinit.text
Date: Tue, 21 Jul 2009 17:00:17 -0700
Message-ID: <4A665691.6080203@zankel.net>
References: <1248211527-32253-1-git-send-email-u.kleine-koenig@pengutronix.de> <1248211527-32253-6-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: =?UTF-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.onlive.com ([74.85.144.12]:1361 "EHLO mx01.onlive.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937AbZGVAJa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 20:09:30 -0400
In-Reply-To: <1248211527-32253-6-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe,

I will add it to the Xtensa tree in the next couple of days (together=20
with other patches that have piled up - still fighting a compiler issue=
).

Thanks,
-Chris


Uwe Kleine-K=C3=B6nig wrote:
> A pointer to xtsonic_probe is passed to the core via
> platform_driver_register and so the function must not disappear when =
the
> .init sections are discarded.  Otherwise (if also having HOTPLUG=3Dy)
> unbinding and binding a device to the driver via sysfs will result in=
 an
> oops as does a device being registered late.
>
> An alternative to this patch is using platform_driver_probe instead o=
f
> platform_driver_register plus removing the pointer to the probe funct=
ion
> from the struct platform_driver.
>
> Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
> Cc: Chris Zankel <chris@zankel.net>
>  =20
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Greg Kroah-Hartman <gregkh@suse.de>
> Cc: netdev@vger.kernel.org
>
> ---
>  drivers/net/xtsonic.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/xtsonic.c b/drivers/net/xtsonic.c
> index 5a4ad15..0c44135 100644
> --- a/drivers/net/xtsonic.c
> +++ b/drivers/net/xtsonic.c
> @@ -239,7 +239,7 @@ out:
>   * Actually probing is superfluous but we're paranoid.
>   */
> =20
> -int __init xtsonic_probe(struct platform_device *pdev)
> +int __devinit xtsonic_probe(struct platform_device *pdev)
>  {
>  	struct net_device *dev;
>  	struct sonic_local *lp;
>  =20

