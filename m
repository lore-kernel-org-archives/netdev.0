From: Valdis.Kletnieks@vt.edu
Subject: Re: linux-next: zillions of lockdep whinges in include/net/sock.h:1408
Date: Sun, 24 Apr 2016 17:13:15 -0400
Message-ID: <181815.1461532395@turing-police.cc.vt.edu>
References: <43037.1461229555@turing-police.cc.vt.edu> <1461245496.7627.17.camel@edumazet-glaptop3.roam.corp.google.com> <5718DA71.7050902@stressinduktion.org> <20160424.143833.2292980084570149367.davem@davemloft.net> <571D14F8.6070306@stressinduktion.org> <1461527202.5535.1.camel@edumazet-glaptop3.roam.corp.google.com> <176911.1461527778@turing-police.cc.vt.edu>
 <1461531617.5535.3.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1461532395_3325P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound.smtp.vt.edu ([198.82.183.121]:43700 "EHLO
	omr2.cc.vt.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753176AbcDXVNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 17:13:20 -0400
In-Reply-To: <1461531617.5535.3.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1461532395_3325P
Content-Type: text/plain; charset=us-ascii

On Sun, 24 Apr 2016 14:00:17 -0700, Eric Dumazet said:
> On Sun, 2016-04-24 at 15:56 -0400, Valdis.Kletnieks@vt.edu wrote:
> > On Sun, 24 Apr 2016 12:46:42 -0700, Eric Dumazet said:
> >
> > > >>> +	return !debug_locks ||
> > > >>> +	       lockdep_is_held(&sk->sk_lock) ||
> >
> > > Issue here is that once lockdep detected a problem (not necessarily in
> > > net/ tree btw), your helper always 'detect' a problem, since lockdep
> > > automatically disables itself.
> >
> > "D'Oh!" -- H. Simpson
> >
> > I thought this patch looked suspect, but couldn't put my finger on it. The
> > reason why I got like 41,000 of them is because I built a kernel that has
> > lockdep enabled, but I have an out-of-tree module that doesn't init something,
> > so I get this:
> >
> > [   48.898156] INFO: trying to register non-static key.
> > [   48.898157] the code is fine but needs lockdep annotation.
> > [   48.898157] turning off the locking correctness validator.
> >
> > After which point, even with this patch, every time through it's still going to
> > explode.
>
> Which patch are you talking about ?

The one that adds the !debug_locks check - once my out-of-kernel module
hits something that turns off lockdep, it's *still* going to complain on
pretty much all the same packets it complained about earlier.  I thought
it looked suspicious, but you clarified why...

--==_Exmh_1461532395_3325P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVx026wdmEQWDXROgAQL+ExAAumVXGpZFomE+Xl8tx+stNi1XuRkraU66
diz/cUIl41nsWsbh96wWdFf16N7jCiZ8jlAultjnw0qfhRksdOP9YzwPDPwQs4hY
Rx23dhXlkpzijATvFqm4spI/RdXnWrDTxOc7rqyj0w06OEy+l8FXp3Efe5ih0igQ
+grFQg8Vjktbb9Wio1gtmCcjwSAh1OlJb3p9AYGvzOc7jguammPVn6ZHu9QL6G9a
EfO340KICZyEMoG/7ka+A6zrgdtpINkHqbTyMO/c0zm6VLTTMn3xOQg0n7+YlHhi
xMMOaWdHVq1KczNgrCLalvSL8WpCnsy1JVfxUrQ7sPkOSdY5f6TvElOG8B2pEDqy
jhCp2PRbCuFpWEmiHa0VbbWF13+MCx1o1tg7liwUKJq1tWH3fRdbFT1yEaFPd3i/
VbRxqywbLVY+5VyDwdPssfuHVGlSZn4etBaLY4P/f+yzK3fNnBWqHcx8XFpwa1kY
P6KrYAbAF/7WcwcPE+GdUt4nXp9j6CwxQLDeIB4JAmO+GcycFyi3L7l28acpfZmj
SAaRHU7T4NM+GqHvPyg04bY9lNGTh0FqkPqksH4pGpGLqGAGQspCpqgKT+GN8YNC
S7Z0D6cQBOTbOapUwdqhPnDbA6LPHkTvRQzuxjwhTrZQ4EuawhqhOzUp/8Llf1ZQ
aEQ1jXzEgwg=
=Jz+M
-----END PGP SIGNATURE-----

--==_Exmh_1461532395_3325P--
