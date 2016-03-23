From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: phy: at803x: Request 'reset' GPIO only for AT8030
 PHY
Date: Wed, 23 Mar 2016 22:42:01 +0300
Message-ID: <56F2F189.1030003@cogentembedded.com>
References: <56E99727.9040702@laposte.net>
 <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net>
 <20160318191242.GQ4292@pengutronix.de> <56EFEDAD.9030903@laposte.net>
 <20160321135457.GX4292@pengutronix.de> <56F0150F.8080804@laposte.net>
 <20160321201229.GA6191@pengutronix.de> <56F157EF.5080307@laposte.net>
 <20160322194224.GF6191@pengutronix.de> <56F26BF7.3090201@laposte.net>
 <56F274A5.6030502@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Sebastian Frias <sf84@laposte.net>,
	=?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:36580 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756114AbcCWTmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 15:42:07 -0400
Received: by mail-lb0-f179.google.com with SMTP id qe11so16784548lbc.3
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 12:42:05 -0700 (PDT)
In-Reply-To: <56F274A5.6030502@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/23/2016 01:49 PM, Sebastian Frias wrote:

> This removes the dependency on GPIOLIB for non faulty PHYs.
>
> Indeed, without this patch, if GPIOLIB is not selected
> devm_gpiod_get_optional() will return -ENOSYS and the driver probe
> call will fail, regardless of the actual PHY hardware.
>
> Out of the 3 PHYs supported by this driver (AT8030, AT8031, AT8035),
> only AT8030 presents the issues that commit 13a56b449325 ("net: phy:
> at803x: Add support for hardware reset") attempts to work-around by
> using a 'reset' GPIO line.
>
> Hence, only AT8030 should depend on GPIOLIB operating properly.
>
> Fixes: 13a56b449325 ("net: phy: at803x: Add support for hardware reset")
>
> Signed-off-by: Sebastian Frias <sf84@laposte.net>
[...]

    What I don't understand is why the link_change_notify() method ptr is 
populated for all 3 supported chips while only being needed on 8030...

MBR, Sergei
