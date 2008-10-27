From: David Miller <davem@davemloft.net>
Subject: Re: tbench wrt. loopback TSO
Date: Mon, 27 Oct 2008 11:39:04 -0700 (PDT)
Message-ID: <20081027.113904.211811887.davem@davemloft.net>
References: <20081027141332.GA4691@ioremap.net>
	<Pine.LNX.4.64.0810271704530.7072@wrl-59.cs.helsinki.fi>
	<20081027170314.GA25148@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org, efault@gmx.de,
	mingo@elte.hu, a.p.zijlstra@chello.nl, herbert@gondor.apana.org.au
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36413
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751058AbYJ0Sj0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 14:39:26 -0400
In-Reply-To: <20081027170314.GA25148@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Evgeniy Polyakov <zbr@ioremap.net>
Date: Mon, 27 Oct 2008 20:03:14 +0300

> On Mon, Oct 27, 2008 at 05:19:17PM +0200, Ilpo J=E4rvinen (ilpo.jarvi=
nen@helsinki.fi) wrote:
> > Noticed that tcp_current_mss does modulo with tso and that it is=20
> > being called from a non-trivial number of places, though ovbiously =
only=20
> > part of them should be relevant here. ...I'm not sure if that can s=
how=20
> > up though.
>=20
> That's why when I see modulo something screams inside me...
> I used following patch (without goto in the tcp_tso_should_defer():

Indeed, those modulos are the worst part about the TSO code.

I'll see what I can do to get rid of them, I hate them too. :-)

One idea immediately occurs to me.  Since we're effectively limited
to a 64K TSO frame, and the MSS is some value smaller than that, we
can probably get away with a reciprocol divide.  Even using a 16-bit
inverse value would suffice, so we wouldn't need to use u64's like
some other pieces of code do.  A u32 would be enough.


