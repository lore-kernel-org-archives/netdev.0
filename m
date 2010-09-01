From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-2.6] 3c59x: Remove incorrect locking; correct
 documented lock hierarchy
Date: Wed, 01 Sep 2010 23:08:27 +0100
Message-ID: <1283378907.5323.287.camel@localhost>
References: <1283213733.7653.180.camel@localhost>
	 <20100901.143815.215547115.davem@davemloft.net>
	 <1283377631.5323.285.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-RBDBEt+9ylwVu0XHyxD1"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36951 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752517Ab0IAWJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 18:09:02 -0400
In-Reply-To: <1283377631.5323.285.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RBDBEt+9ylwVu0XHyxD1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-09-01 at 22:47 +0100, Ben Hutchings wrote:
> On Wed, 2010-09-01 at 14:38 -0700, David Miller wrote:
> > From: Ben Hutchings <ben@decadent.org.uk>
> > Date: Tue, 31 Aug 2010 01:15:33 +0100
> >=20
> > > vortex_ioctl() was grabbing vortex_private::lock around its call to
> > > generic_mii_ioctl().  This is no longer necessary since there are mor=
e
> > > specific locks which the mdio_{read,write}() functions will obtain.
> > > Worse, those functions do not save and restore IRQ flags when locking
> > > the MII state, so interrupts will be enabled when generic_mii_ioctl()
> > > returns.
> > >=20
> > > Since there is currently no need for any function to call
> > > mdio_{read,write}() while holding another spinlock, do not change the=
m
> > > to save and restore IRQ flags but remove the specification of orderin=
g
> > > between vortex_private::lock and vortex_private::mii_lock.
> > >=20
> > > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> > > ---
> > > I've now borrowed a card to test 3c59x on.  I've seen another regress=
ion
> > > reported <http://bugs.debian.org/586967> after my locking changes, wh=
ich
> > > I can't reproduce.
> >=20
> > I think the lock is necessary, in some form.
> >=20
> > Nothing otherwise protects vp->mii, which is accessed and modified by
> > not just this ioctl, but also ethtool operation calls.
> >=20
> > So we can't apply your patch as-is.
>=20
> Hmm, yes, I forgot that mii caches information in struct mii_if_info.
> Let me rethink this.

I think this is safe after all because ethtool and MII ioctls are all
serialised by the RTNL.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-RBDBEt+9ylwVu0XHyxD1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATH7O1ue/yOyVhhEJAQK3/hAAosYXA3t4DgrWlX+VAY5o3vuOTdC3aPeO
tjz6cu9ySeDrRqSInr79ABp8aoOVplmuRkvGZmobtl1Z4B6jS+m4GBojysxMF84P
1i6cpnWo9AdUFmAB+9H0xhwd3O6T3Vho2fitzyqJR3NE9bFJQynonrSnQGKjhU8K
7Utt9kwqKncg8pi2XTQmCV+t1ZWDZ1tfQqB34qhKL51V0Hea2EiGwMb4X21NdviP
+35HbOJuS9WpcU+Jep06MgQwC4z0/Plb2R+lsWPm3RPTobCX6UOwhb9diSyRKjEo
WQAVM+wE+tFPIiyi2Uk8RvA71irZLPuB7055RWbrflHiOxtxKVM2OjY4DAGEUZc3
GlmytTmugi5uE+SYGHGCKR0a69hnyPL0iHTdDpD3ILV5Gv/8kHdZaGe/iQSuaU/C
MHWJ0zTJy/8v5a7qKt7yRbcj1ijwOxq+hdh9bnDAJXeO0u2ttH0YfxkdxGZchBfX
Eko/O3I7hedPgjilMvW7fDzTH1E4ax14GgkW+7Jmmws4zkHitJOffsi1NxyTuc2U
+ap73edZvCReKsc/zEFqu/jPvyr0UeavKdVsvx0/iwG8FxHx2gjpLYZ+6mUTyS7/
WPiZfq+XSc4QVGU3/f/yl8ZfPcDTMCVZY/xdWWL36nYam4maa0OzfGqtjbXl+UFK
aPoVP27yGQY=
=vcdQ
-----END PGP SIGNATURE-----

--=-RBDBEt+9ylwVu0XHyxD1--
