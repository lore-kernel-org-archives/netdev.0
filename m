From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 2/2] ehea: add memory remove hotplug support
Date: Tue, 05 Feb 2008 10:14:21 +1100
Message-ID: <1202166861.7672.11.camel@concordia>
References: <200802041404.49960.ossthema@de.ibm.com>
	 <1202136362.7672.5.camel@concordia>
	 <200802041624.31228.ossthema@de.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-iipiDIJciz2breTnx5if"
Cc: Jeff Garzik <jeff@garzik.org>, Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57469 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756696AbYBDXOl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2008 18:14:41 -0500
In-Reply-To: <200802041624.31228.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-iipiDIJciz2breTnx5if
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Mon, 2008-02-04 at 16:24 +0100, Jan-Bernd Themann wrote:
> On Monday 04 February 2008 15:46, Michael Ellerman wrote:
> > On Mon, 2008-02-04 at 14:04 +0100, Jan-Bernd Themann wrote:
> > > Add memory remove hotplug support
>=20
> > > @@ -3559,6 +3578,10 @@ int __init ehea_module_init(void)
> > >  	if (ret)
> > >  		ehea_info("failed registering reboot notifier");
> > > =20
> > > +	ret =3D register_memory_notifier(&ehea_mem_nb);
> > > +	if (ret)
> > > +		ehea_info("failed registering memory remove notifier");
> > >=20
> > >  	ret =3D crash_shutdown_register(&ehea_crash_handler);
> > >  	if (ret)
> > >  		ehea_info("failed registering crash handler");
> >=20
> > You don't do anything except print a message if the registration fails.
> > What happens when someone tries to remove memory but the memory notifie=
r
> > wasn't registered properly? Bang?
>=20
> In case the registration fails and somebody tries to free memory:
> - Driver will not remove the affected memory from the eHEA memory region
>   --> Firmware (phyp) can not free that memory (as marked as used)
>   --> Therefore the removed memory could not be used in an other partitio=
n
>=20
> It makes sense to allow the driver to work anyway. Having no ethernet
> would not really be a good alternative.

Yeah I agree. I wasn't clear from the patch that no notifier -> no
memory removed. Rather than, no notifier -> memory removed and ehea
isn't told about it.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-iipiDIJciz2breTnx5if
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHp5xNdSjSd0sB4dIRAiwaAJ92Njb5iA7hlwLtIey0a+wqOxaoGQCffA8q
+zpHkSlLUqJ9i1aMOFOhKTg=
=N88B
-----END PGP SIGNATURE-----

--=-iipiDIJciz2breTnx5if--

