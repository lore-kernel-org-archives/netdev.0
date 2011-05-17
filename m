From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: sfc: an enumeration is not a bitmask
Date: Tue, 17 May 2011 20:22:27 +0100
Message-ID: <1305660147.2848.37.camel@bwh-desktop>
References: <20110517.141446.140687548350861625.davem@davemloft.net>
	 <BANLkTi=n_0JiF0Lm=+1OwRzB4XQFBtg8KA@mail.gmail.com>
	 <BANLkTinaO0VVGpRRqRauH6FucvwbcXyRUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52494 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756504Ab1EQTWa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 15:22:30 -0400
In-Reply-To: <BANLkTinaO0VVGpRRqRauH6FucvwbcXyRUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-17 at 21:09 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> 2011/5/17 Jeff Garzik <jgarzik@pobox.com>:
> > 2011/5/17 David Miller <davem@davemloft.net>:
> >> An enumeration is not a bitmask, instead it means one out of the s=
et
> >> of enumerated values will be used.
> >
> > It's a decade-old kernel practice to use 'enum' to define typed
> > constants, preferred over  macros that convey no type information a=
nd
> > disappear after cpp phase.
> >
> > So your assertion about enumerations is demonstrably not true, as i=
t
> > is often used in the kernel.  Call it enum abuse if you want, but i=
t
> > is consistent with code all over the kernel.
> >
> > That said, I agree that warnings should of course be addressed in s=
ome manner.
>=20
> Old age of the mistake doesn't make it correct.
>=20
> Disappearance of the #defines can be resolved by using enum of bit
> positions (and maybe field lengths) and #define of (1 << bit_position=
)
> if it is useful for something to remain after preprocessing.

The point is that there is no specific type information for macros,
whether they are simple literal numbers or left-shift expressions.

The type of an enumerator in C is actually that of the underlying
integer type, not the enumeration type as in C++.  However, a compiler
or static analysis tool (such as sparse) may keep track of both the
language-specified type and some other associated type of an expression
in order to diagnose possible type errors.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

