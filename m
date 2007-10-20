From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [BUG] powerpc does not save msi state [was Re: [PATCH 5/7]
	pci: Export the pci_restore_msi_state() function
Date: Sat, 20 Oct 2007 16:43:26 +1000
Message-ID: <1192862606.7688.4.camel@concordia>
References: <20071020000421.GO29903@austin.ibm.com>
	 <20071019.172706.57467960.davem@davemloft.net>
	 <20071020004610.GR29903@austin.ibm.com>
	 <20071019.175308.54212640.davem@davemloft.net>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-aq0Acc+KUBv8htLj/ljW"
Cc: linas@austin.ibm.com, linuxppc-dev@ozlabs.org, mchan@broadcom.com,
	mcarlson@broadcom.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54122 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760814AbXJTGn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Oct 2007 02:43:29 -0400
In-Reply-To: <20071019.175308.54212640.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-aq0Acc+KUBv8htLj/ljW
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Fri, 2007-10-19 at 17:53 -0700, David Miller wrote:
> From: linas@austin.ibm.com (Linas Vepstas)
> Date: Fri, 19 Oct 2007 19:46:10 -0500
>=20
> > FWIW, it looks like not all that many arches do this; the output
> > for grep -r address_hi * is pretty thin. Then, looking at
> > i386/kernel/io_apic.c as an example, one can see that the=20
> > msi state save happens "by accident" if CONFIG_SMP is enabled;
> > and so its surely broekn on uniprocesor machines.
>=20
> I don't see this, in all cases write_msi_msg() will transfer
> the given "*msg" to entry->msg by this assignment in
> drivers/pci/msi.c:
>=20
> void write_msi_msg(unsigned int irq, struct msi_msg *msg)
> {
>  ...
> 	entry->msg =3D *msg;
> }
>=20
> So as long as write_msi_msg() is invoked, it will be saved
> properly.
>=20
> Platforms need not do this explicitly.

I'm short on context here, and it's Saturday, so excuse me if I'm
missing the point somewhere.

On pseries machines we don't call write_msi_msg(), because we don't
control the contents of the message, firmware does. So entry->msg will
be bogus.

That's a pity, but AFAIK it shouldn't be a problem because we don't
enable CONFIG_PM on those machines anyway. If we ever want to we'll need
to sort out with firmware how that will work WRT restoring MSI state.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-aq0Acc+KUBv8htLj/ljW
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHGaOOdSjSd0sB4dIRAhn5AJ9WqJzo9B87WoF498YpuWUT+42mAgCgq+/L
iUIVrYJgJ6OKna7G4zAbc5U=
=h7Up
-----END PGP SIGNATURE-----

--=-aq0Acc+KUBv8htLj/ljW--

