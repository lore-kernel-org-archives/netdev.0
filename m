From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: net: fec: make driver endian-safe
Date: Sun, 24 Jan 2016 08:26:13 +0100
Message-ID: <1453620373.2453.6.camel@sipsolutions.net>
References: <1453586940-21181-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Ungerer <gerg@uclinux.org>,
	Lucas Stach <l.stach@pengutronix.de>,
	Fugang Duan <B38611@freescale.com>,
	Arnd Bergmann <arnd@arndb.de>, Shawn Guo <shawnguo@kernel.org>,
	Kevin Hilman <khilman@linaro.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:52936 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750764AbcAXH0R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jan 2016 02:26:17 -0500
In-Reply-To: <1453586940-21181-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-01-23 at 23:09 +0100, Johannes Berg wrote:
>=C2=A0
> +/* buffer endianness appears to be a mess ... ARM is usually LE but
> can be BE */
> +#if defined(CONFIG_ARM) && defined(CONFIG_CPU_BIG_ENDIAN)

Just realized that this is, of course, completely wrong. If the ARM CPU
is little endian, the device is of course *still* little endian, it
doesn't magically change itself with the CONFIG_CPU_BIG_ENDIAN
setting... :)

Ergo, the #if part should be taken, rather than the #else part, to
still define the descriptors as __le and just have no byteswapping
done.

Also, as Arnd had pointed out last night but I wasn't coherent enough
to fully understand, it's exceedingly likely that

> =C2=A0#if defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)

this needs to be changed and that the device is simply "generated" as
little-endian for ARM SoCs. He also pointed out that there could be
multiple CONFIG_SOC or CONFIG_ARCH definitions (if I understood
correctly), so this would be wrong anyway.

It's tempting to combine both ifdefs and change them to just CONFIG_ARM
but I have no way of verifying that on anything other than i.MX6 (on
the hummingboard), nor do I even know which SoCs ship with this block.

johannes
