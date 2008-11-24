From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] eth: Declare an optimized compare_ether_addr_64bits()
 function
Date: Sun, 23 Nov 2008 22:46:21 -0800 (PST)
Message-ID: <20081123.224621.07006022.davem@davemloft.net>
References: <4927B275.1030407@cosmosbay.com>
	<20081123.154554.255301279.davem@davemloft.net>
	<492A4962.1080400@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48550
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751150AbYKXGqW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 01:46:22 -0500
In-Reply-To: <492A4962.1080400@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 24 Nov 2008 07:27:46 +0100

> David Miller a =E9crit :
> > From: Eric Dumazet <dada1@cosmosbay.com>
> > Date: Sat, 22 Nov 2008 08:19:17 +0100
> >=20
> >> This patch implements a compare_ether_addr_64bits() function, that
> >> handles the case of x86 cpus, but might be used on other arches as
> >> well, if their potential misaligned long word reads are not
> >> expensive.
> > We have a test for this, HAVE_EFFICIENT_UNALIGNED_ACCESS
> > Please use that instead of CONFIG_X86 and I'll apply this
> > to net-next-2.6
> >=20
>=20
> Excellent !
>=20
> I missed this cool feature.

Sorry, one last nit.

If the platform defines HAVE_EFFICIENT_UNALIGNED_ACCESS, there
is not point in going and using the get_unaligned() interfaces.
They are by definition a NOP in such cases.

So I toss them while applying this second version of your
patch, thanks!
