From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Use of ENOTSUPP in drivers?
Date: Sun, 12 Jan 2014 13:19:36 -0800
Message-ID: <1408352.Qio0cxKTUV@lenovo>
References: <20140112185715.GB5405@kria> <1389559622.3720.115.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:36015 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaALVTk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 16:19:40 -0500
Received: by mail-ob0-f182.google.com with SMTP id wn1so4929896obc.41
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 13:19:39 -0800 (PST)
In-Reply-To: <1389559622.3720.115.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 12 janvier 2014, 20:47:02 Ben Hutchings a =E9crit :
> On Sun, 2014-01-12 at 19:57 +0100, Sabrina Dubroca wrote:
> > Thu, 2 Jan 2014 12:01:31 +0000, Ben Hutchings wrote:
> > > Never return error code ENOTSUPP; it's *not* the same thing as EN=
OTSUP
> > > in userland and is not part of the userland ABI.  I would use EIN=
VAL
> > > here.
> >=20
> > I've found a few ethernet drivers that return -ENOTSUPP in various
> > functions. In particular, some ethtool functions or ioctl's.
> > Ben's message makes me think that the ethtool functions and ioctl's
> > should be modified.
> >=20
> > There are other occurences, mostly in functions related to device
> > initialization. I didn't manage to track down exactly from where so=
me
> > of them are called, and I don't know if ENOTSUPP is okay in these.
> >=20
> > I've included the complete list of occurences (based on net-next) f=
rom
> > drivers/net/ethernet in patch form at the end, if that's more
> > convenient than the file/function list. This is not meant to be
> > applied.
> >=20
> >=20
> > Do these (or part of them) need to be patched? Or is there somethin=
g
> > I'm missing?
>=20
> [...]
>=20
> I believe they should all be patched.  According to
> include/linux/errno.h, ENOTSUPP is meant for use in the NFSv3 code on=
ly.
> (But it's apparently erroneously used *all over* the tree, not just i=
n
> net drivers!)

Most other drivers use -EOPNOTSUPP, which is arguably as bad as -ENOTSU=
PP,=20
since the comment about it says:

* Operation not supported on transport endpoint *

But at least changing -ENOTSUPP to -EOPNOTSUPP until something better w=
hich is=20
not protocol/endpoint specific is agreed on might be better for consist=
ency?
--=20
=46lorian
