From: Willy Tarreau <w@1wt.eu>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via /proc
Date: Mon, 8 Nov 2010 02:00:42 +0100
Message-ID: <20101108010042.GA13384@1wt.eu>
References: <1289074307.3090.100.camel@Dan> <AANLkTimC01SViEOObgf2N2VcLTYO59rOAbHaKf2RM54w@mail.gmail.com> <20101106.165703.193714684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, chas@cmf.nrl.navy.mil,
	security@kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, drosenberg@vsecurity.com,
	jmorris@namei.org, remi.denis-courmont@nokia.com,
	kuznet@ms2.inr.ac.ru, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:47209 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752297Ab0KHBHP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Nov 2010 20:07:15 -0500
Content-Disposition: inline
In-Reply-To: <20101106.165703.193714684.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 06, 2010 at 04:57:03PM -0700, David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Sat, 6 Nov 2010 13:50:32 -0700
>=20
> > On Saturday, November 6, 2010, Dan Rosenberg <drosenberg@vsecurity.=
com> wrote:
> >>
> >> Clearly, in most cases we cannot just remove the field from the /p=
roc
> >> output, as this would break a number of userspace programs that re=
ly on
> >> consistency. =A0However, I propose that we replace the address wit=
h a "0"
> >> rather than leaking this information.
> >=20
> > I really think it would be much better to use the unidentified numb=
er
> > or similar.
> >=20
> > Just replacing with zeroes is annoying, and has the potential of
> > losing actual information.
>=20
> I would really like to see the specific examples of where this is
> happening, it sounds like something very silly to me.

It has happened to me several times to use an hex editor to check some
socket's parameters (eg: backlog) based on the pointer. Sometimes I had
even change some parameters at runtime as part of debugging sessions.

In fact we could consider than many places that return pointers could
return 0 to normal users and the real value only to root (or any specia=
l
capability). I find it important not to reduce the observability of the
kernel for the sake of security.

Regards,
Willy

