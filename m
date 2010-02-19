From: Bruce Cran <bruce@cran.org.uk>
Subject: Re: connect() sometimes succeeds when it shouldn't
Date: Fri, 19 Feb 2010 10:55:39 +0000
Message-ID: <201002191055.39244.bruce@cran.org.uk>
References: <201002181947.11125.bruce@cran.org.uk> <alpine.DEB.2.00.1002190053260.16302@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muon.cran.org.uk ([109.74.192.160]:54838 "EHLO muon.cran.org.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753756Ab0BSKzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2010 05:55:17 -0500
In-Reply-To: <alpine.DEB.2.00.1002190053260.16302@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 18 February 2010 23:09:09 Ilpo J=E4rvinen wrote:
> On Thu, 18 Feb 2010, Bruce Cran wrote:
> > I've found that if I run a program that does lots of calls to conne=
ct()
> > then it will eventually succeed when there's no server listening. F=
or
> > SCTP it takes a few thousand, for TCP up to a couple of million.  I=
 first
> > came across the problem in Windows, where the connection was being
> > processed so quickly that by the time the handler function had fini=
shed,
> > the 'connecting' flag had already been reset, which wasn't expected=
=2E I've
> > not checked the Linux sources to see if something similar is happen=
ing
> > though.
> >
> > The machine I tested it on was running a 2.6.32 i686 kernel.
> >
> > The test code can be found at
> > http://www.cran.org.uk/~brucec/linux/badconnect.c
>=20
> Perhaps you just managed to dial your own number? ...Please try with
> my improved version of badconnect.c below. :-)

That was the problem: calling bind() before connect() fixed it. Sorry f=
or the=20
noise.

--=20
Bruce Cran
