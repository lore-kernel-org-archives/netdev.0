From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: sfc: Add driverlink API to support virtual NIC drivers
Date: Mon, 17 Nov 2008 20:48:27 +0000
Message-ID: <1226954907.18421.2.camel@achroite>
References: <20081116.004557.210684346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:38252 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752394AbYKQUsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 15:48:33 -0500
In-Reply-To: <20081116.004557.210684346.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=EF=BB=BFOn Sun, 2008-11-16 at 00:45 -0800, David Miller wrote:
> I'm not applying this patch, it is just a gateway for proprietary
> extensions to the driver.

=EF=BB=BFWe have no interest in creating proprietary extensions.  All e=
xisting
driverlink clients are either licenced under GPLv2 or are unreleased
debugging tools.  I hadn't thought of it before, but we could change th=
e
EXPORT_SYMBOLs to EXPORT_SYMBOL_GPL.

> The fact that it allows any module to hook into the driver and
> decide how to handle every TX or RX frame basically makes this
> change a non-starter.

This is unpleasant but seems to be necessary.  The reason for this hook
was explained by my colleague Robert Stonehouse in a covering mail =EF=BB=
=BF
<http://article.gmane.org/gmane.linux.network/96546> for an earlier
version of this patch:

"They are needed partly because the filtering of received packets onto
V-NICs is imperfect, and in Xen to spot certain control plane updates
efficiently."

Existing driverlink clients only inspect packets rather than modifying
them, and it might be possible for them to do without the "veto" option=
=2E
Maybe we could even use netfilter, though I suspect that would be
fragile.

> Many many years ago, various vendor drivers tried to do something
> similar, so that their proprietary bonding modules could work,
> and instead we improved the Linux bonding driver to have feature
> parity with whatever those guys were offering.

Well, Robert has explained the requirements we're trying to satisfy.
Can you suggest how we might implement these in a way that you would be
happy with?

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

