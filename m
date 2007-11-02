From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH] ehea: add kexec support
Date: Fri, 02 Nov 2007 17:30:08 +1100
Message-ID: <1193985008.1782.7.camel@concordia>
References: <200710261437.29117.ossthema@de.ibm.com>
	 <1193610737.9637.1.camel@concordia>
	 <OF79E7ACE7.5D0488CE-ONC1257384.002E58C0-C1257384.002F8561@de.ibm.com>
	 <1193784636.32504.4.camel@concordia>
	 <OF59B5FFD2.0294206F-ONC1257385.006A802D-C1257385.006CB6BB@de.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-y5rS4QiXPITsc4bYsb2F"
Cc: Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <MEDER@de.ibm.com>,
	netdev <netdev@vger.kernel.org>, ossthema@linux.vnet.ibm.com,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Thomas Q Klein <TKLEIN@de.ibm.com>
To: Christoph Raisch <RAISCH@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60580 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751763AbXKBGaK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2007 02:30:10 -0400
In-Reply-To: <OF59B5FFD2.0294206F-ONC1257385.006A802D-C1257385.006CB6BB@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-y5rS4QiXPITsc4bYsb2F
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-31 at 20:48 +0100, Christoph Raisch wrote:
> Michael Ellerman <michael@ellerman.id.au> wrote on 30.10.2007 23:50:36:
> >
> > On Tue, 2007-10-30 at 09:39 +0100, Christoph Raisch wrote:
> > >
> > > Michael Ellerman <michael@ellerman.id.au> wrote on 28.10.2007 23:32:1=
7:
> > > Hope I didn't miss anything here...
> >
> > Perhaps. When we kdump the kernel does not call the reboot notifiers, s=
o
> > the code Jan-Bernd just added won't get called. So the eHEA resources
> > won't be freed. When the kdump kernel tries to load the eHEA driver wha=
t
> > will happen?
> >
> Good point.
>=20
> If the device driver tries to allocate resources again (in the kdump
> kernel),
> which have been allocated before (in the crashed kernel) the hcalls will
> fail because from the hypervisor view the resources are still in use.
> Currently there's no method to find out the resource handles for these
> HEA resources allocated by the crashed kernel within the hypervisor...

So the hypervisor can't allocate more resources, because they're already
allocated, but it can't free the ones that are allocated because it
doesn't know what they are? I don't think I understand.

If that's really the way it works then eHEA is more or less broken for
kdump I'm afraid.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-y5rS4QiXPITsc4bYsb2F
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKsPwdSjSd0sB4dIRAh3iAJ9/4vrJwKDDsiW94b+10eQT3MKwTACgkTu4
PT5eL1afNH+NriyRW+7COPY=
=qa+e
-----END PGP SIGNATURE-----

--=-y5rS4QiXPITsc4bYsb2F--

