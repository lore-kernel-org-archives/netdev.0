From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH v2] net: smc91x: fix SMC accesses
Date: Sun, 28 Aug 2016 00:09:49 +0200
Message-ID: <87r399eudu.fsf@belgarion.home>
References: <E1bdgXX-0005I4-1N@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-arm-kernel@lists.infradead.org,
        Nicolas Pitre <nico@fluxnic.net>,
        Arnd Bergmann <arnd@arndb.de>, Daniel Mack <daniel@zonque.org>,
        Haojian Zhuang <haojian.zhuang@gmail.com>,
        Steven Miao <realmz6@gmail.com>,
        adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp11.smtpout.orange.fr ([80.12.242.133]:20031 "EHLO
        smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754209AbcH0WJz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 18:09:55 -0400
In-Reply-To: <E1bdgXX-0005I4-1N@rmk-PC.armlinux.org.uk> (Russell King's
        message of "Sat, 27 Aug 2016 17:33:03 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell King <rmk+kernel@armlinux.org.uk> writes:

> Commit b70661c70830 ("net: smc91x: use run-time configuration on all ARM
> machines") broke some ARM platforms through several mistakes.  Firstly,
> the access size must correspond to the following rule:
>
> (a) at least one of 16-bit or 8-bit access size must be supported
> (b) 32-bit accesses are optional, and may be enabled in addition to
>     the above.
>
> Secondly, it provides no emulation of 16-bit accesses, instead blindly
> making 16-bit accesses even when the platform specifies that only 8-bit
> is supported.
>
> Reorganise smc91x.h so we can make use of the existing 16-bit access
> emulation already provided - if 16-bit accesses are supported, use
> 16-bit accesses directly, otherwise if 8-bit accesses are supported,
> use the provided 16-bit access emulation.  If neither, BUG().  This
> exactly reflects the driver behaviour prior to the commit being fixed.
>
> Since the conversion incorrectly cut down the available access sizes on
> several platforms, we also need to go through every platform and fix up
> the overly-restrictive access size: Arnd assumed that if a platform can
> perform 32-bit, 16-bit and 8-bit accesses, then only a 32-bit access
> size needed to be specified - not so, all available access sizes must
> be specified.
>
> This likely fixes some performance regressions in doing this: if a
> platform does not support 8-bit accesses, 8-bit accesses have been
> emulated by performing a 16-bit read-modify-write access.
>
> Tested on the Intel Assabet/Neponset platform, which supports only 8-bit
> accesses, which was broken by the original commit.
>
> Fixes: b70661c70830 ("net: smc91x: use run-time configuration on all ARM machines")
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
> ---
> Robert, this is the full patch - can I add your tested-by to this for
> the subset patch please?
Yes, I just retested it, so :
Tested-by: Robert Jarzmik <robert.jarzmik@free.fr>

Cheers.
