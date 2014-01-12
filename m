From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Use of ENOTSUPP in drivers?
Date: Sun, 12 Jan 2014 21:39:21 +0000
Message-ID: <1389562761.3720.124.camel@deadeye.wl.decadent.org.uk>
References: <20140112185715.GB5405@kria>
	 <1389559622.3720.115.camel@deadeye.wl.decadent.org.uk>
	 <1408352.Qio0cxKTUV@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sabrina Dubroca <sd@queasysnail.net>, <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50959 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbaALVjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 16:39:25 -0500
In-Reply-To: <1408352.Qio0cxKTUV@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-12 at 13:19 -0800, Florian Fainelli wrote:
> Le dimanche 12 janvier 2014, 20:47:02 Ben Hutchings a =C3=A9crit :
> > On Sun, 2014-01-12 at 19:57 +0100, Sabrina Dubroca wrote:
> > > Thu, 2 Jan 2014 12:01:31 +0000, Ben Hutchings wrote:
> > > > Never return error code ENOTSUPP; it's *not* the same thing as =
ENOTSUP
> > > > in userland and is not part of the userland ABI.  I would use E=
INVAL
> > > > here.
> > >=20
> > > I've found a few ethernet drivers that return -ENOTSUPP in variou=
s
> > > functions. In particular, some ethtool functions or ioctl's.
> > > Ben's message makes me think that the ethtool functions and ioctl=
's
> > > should be modified.
> > >=20
> > > There are other occurences, mostly in functions related to device
> > > initialization. I didn't manage to track down exactly from where =
some
> > > of them are called, and I don't know if ENOTSUPP is okay in these=
=2E
> > >=20
> > > I've included the complete list of occurences (based on net-next)=
 from
> > > drivers/net/ethernet in patch form at the end, if that's more
> > > convenient than the file/function list. This is not meant to be
> > > applied.
> > >=20
> > >=20
> > > Do these (or part of them) need to be patched? Or is there someth=
ing
> > > I'm missing?
> >=20
> > [...]
> >=20
> > I believe they should all be patched.  According to
> > include/linux/errno.h, ENOTSUPP is meant for use in the NFSv3 code =
only.
> > (But it's apparently erroneously used *all over* the tree, not just=
 in
> > net drivers!)
>=20
> Most other drivers use -EOPNOTSUPP, which is arguably as bad as -ENOT=
SUPP,=20
> since the comment about it says:
>=20
> * Operation not supported on transport endpoint *
>=20
> But at least changing -ENOTSUPP to -EOPNOTSUPP until something better=
 which is=20
> not protocol/endpoint specific is agreed on might be better for consi=
stency?

It is not as bad, because EOPNOTSUPP is actually named in userland (in
fact it has two names, the other being ENOTSUP spelt with *one* P).

glibc's strerror() returns these strings for ENOTSUPP and EOPNOTSUPP
respectively:

"Unknown error 524"
"Operation not supported"

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
