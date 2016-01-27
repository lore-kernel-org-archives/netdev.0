From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 8/9] net: nb8800: avoid uninitialized variable warning
Date: Wed, 27 Jan 2016 16:21:54 +0100
Message-ID: <8558854.EA4z9rFkjX@wuerfel>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de> <1453903507-3427225-9-git-send-email-arnd@arndb.de> <yw1xsi1jjekj.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:65204 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932740AbcA0PWa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 10:22:30 -0500
In-Reply-To: <yw1xsi1jjekj.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 27 January 2016 14:13:16 M=E5ns Rullg=E5rd wrote:
> Arnd Bergmann <arnd@arndb.de> writes:
>=20
> > The nb8800_poll() function initializes the 'next' variable in the
> > loop looking for new input data. We know this will be called at
> > least once because 'budget' is a guaranteed to be a positive number
> > when we enter the function, but the compiler doesn't know that
> > and warns when the variable is used later:
> >
> > drivers/net/ethernet/aurora/nb8800.c: In function 'nb8800_poll':
> > drivers/net/ethernet/aurora/nb8800.c:350:21: warning: 'next' may be=
 used uninitialized in this function [-Wmaybe-uninitialized]
>=20
> Which gcc version is this?  4.9 doesn't warn here, presumably because
> it's clever enough to notice that the offending use of 'next' is unde=
r a
> condition that can only be true if the first one was.  Of course fixi=
ng
> the code so older compilers don't warn is a good idea.

This was with gcc-5.2.1, but possibly in an unusual kernel configuratio=
n.
The only time I see it in my logs was with CONFIG_ARCH_IXP4XX=3Dy, whic=
h
has its own mach/io.h and other headers that sometimes override generic
functions with a more elaborate version.

I have another patch for ixp4xx that simplifies its mach/io.h in order =
to
get rid of other false 'uninitialized use' warnings, but this one still
shows up with that other patch.

> > Changing the 'while() {}' loop to 'do {} while()' makes it obvious
> > to the compiler what is going on so it no longer warns.
> >
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>=20
> Acked-by: Mans Rullgard <mans@mansr.com>

Thanks,

	Arnd
