From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: Re: [PATCHES] Networking fixes for -stable.
Date: Wed, 14 Nov 2012 15:02:22 +0100
Message-ID: <CA+MoWDqOd_0jOvFpqkqtSePRV--O8A2tfG71d_VpkUfN89Q_FQ@mail.gmail.com>
References: <20121112.002558.46179003870204789.davem@davemloft.net>
	<1352836286.16264.102.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:47064 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422942Ab2KNOCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 09:02:25 -0500
In-Reply-To: <1352836286.16264.102.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Tue, Nov 13, 2012 at 8:51 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Mon, 2012-11-12 at 00:25 -0500, David Miller wrote:
>> Please queue up the following networking bug fixes for
>> 3.0.x, 3.2.x, 3.4.x, and 3.6.x, respectively.
> [...]
>> From 2204849a85383fbde75680aa199142abe504adbb Mon Sep 17 00:00:00 2001
>> From: Peter Senna Tschudin <peter.senna@gmail.com>
>> Date: Sun, 28 Oct 2012 06:12:01 +0000
>> Subject: [PATCH 7/9] drivers/net/phy/mdio-bitbang.c: Call mdiobus_unregister
>>  before mdiobus_free
>>
>> [ Upstream commit aa731872f7d33dcb8b54dad0cfb82d4e4d195d7e ]
>>
>> Based on commit b27393aecf66199f5ddad37c302d3e0cfadbe6c0
>>
>> Calling mdiobus_free without calling mdiobus_unregister causes
>> BUG_ON(). This patch fixes the issue.
> [...]
>
> This introduces a regresssion, as mdiobus_unregister() is not safe to
> call if the bus isn't registered.  Registration is controlled by the
> drivers that use mdio-bitbang, and they should take care of
> unregistration too - and most of them do.

Is mdiobus_free() safe to call if the bus isn't registered?

I found calls to free_mdio_bitbang() after call to
mdiobus_unregister() that may be the worst cases for my patch. But I
also found places that call free_mdio_bitbang() without first calling
mdiobus_unregister(). See:

linux-next/arch/powerpc/platforms/82xx/ep8248e.c:152
linux-next/drivers/net/ethernet/8390/ax88796.c:647
linux-next/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c:197
linux-next/drivers/net/phy/mdio-gpio.c:157
linux-next/drivers/net/phy/mdio-gpio.c:172

Are those calls to free_mdio_bitbang() wrong by not calling
mdiobus_unregister() before?

>
> This should be reverted in mainline and not applied to any stable
> series.
>
> Ben.
>
> --
> Ben Hutchings
> For every complex problem
> there is a solution that is simple, neat, and wrong.

Thank you for reviewing,

Peter

--
Peter
