From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] net: smc91x: use run-time configuration on all ARM machines
Date: Sat, 28 Feb 2015 17:50:46 +0100
Message-ID: <877fv22d5l.fsf@free.fr>
References: <2226303.iMQTNXSl1n@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Linus Walleij <linus.walleij@linaro.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.smtpout.orange.fr ([80.12.242.124]:55021 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbbB1Qux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 11:50:53 -0500
In-Reply-To: <2226303.iMQTNXSl1n@wuerfel> (Arnd Bergmann's message of "Wed, 25
	Feb 2015 16:31:57 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> writes:

> The smc91x driver traditionally gets configured at compile-time
> for whichever hardware it runs on. This no longer works on
> ARM as we continue to move to building all-in-one kernels.
>
> Most ARM configurations with this driver already use run-time
> configuration through DT or through platform_data, but a
> few have not been converted yet.
>
> I've checked all ARM boards that use this driver in their
> legacy board files, and converted the ones that were using
> compile-time configuration in smc91x.h to behave like the
> other ones and provide the interrupt polarity along with
> the MMIO configuration (width, stride) at platform device
> creation time.
>
> In particular, these combinations were previously selectable
> in Kconfig but in fact broken:
>
> - sa1100 assabet plus pleb
> - msm combined with any other armv6/v7 platform
> - pxa-idp combined with any non-DMA pxa variant
> - LogicPD PXA270 combined with any other pxa
> - nomadik combined with any other armv4/v5 platform,
>   e.g. versatile.
>
> None of these seem critical enough to warrant a backport
> to stable, but it would be nice to clean this up for good.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ----
> I would like the patch to get merged through netdev, after
> Robert and/or Linus have verified it on at least some hardware.
For lubbock (smcs 91c96) and zylonite (smcs 91c111) :
Tested-by: Robert Jarzmik <robert.jarzmik@free.fr>

Cheers.

--
Robert

PS: My mainstone is a bit uncooperative right now, I'll have to convince her to
boot in the near future ...
