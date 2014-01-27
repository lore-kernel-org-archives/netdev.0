From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] net: hyperv: initialize link status correctly
Date: Mon, 27 Jan 2014 10:30:38 +0000
Message-ID: <1390818638.2735.136.camel@deadeye.wl.decadent.org.uk>
References: <1390807854-4469-1-git-send-email-jasowang@redhat.com>
 <20140127.003559.2290408024387922847.davem@davemloft.net>
 <52E629A8.5010302@redhat.com>
 <1390818121.2735.130.camel@deadeye.wl.decadent.org.uk>
 <52E634DA.3040200@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4544982949310501754=="
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
 David Miller <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <52E634DA.3040200@redhat.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org


--===============4544982949310501754==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-56IykHN8/pSwD5rjO7vl"


--=-56IykHN8/pSwD5rjO7vl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-01-27 at 18:28 +0800, Jason Wang wrote:
> On 01/27/2014 06:22 PM, Ben Hutchings wrote:
> > On Mon, 2014-01-27 at 17:40 +0800, Jason Wang wrote:
> >> On 01/27/2014 04:35 PM, David Miller wrote:
> >>> From: Jason Wang <jasowang@redhat.com>
> >>> Date: Mon, 27 Jan 2014 15:30:54 +0800
> >>>
> >>>> Call netif_carrier_on() after register_device(). Otherwise it won't =
work since
> >>>> the device was still in NETREG_UNINITIALIZED state.
> >>>>
> >>>> Fixes a68f9614614749727286f675d15f1e09d13cb54a
> >>>> (hyperv: Fix race between probe and open calls)
> >>>>
> >>>> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> >>>> Cc: K. Y. Srinivasan <kys@microsoft.com>
> >>>> Reported-by: Di Nie <dnie@redhat.com>
> >>>> Tested-by: Di Nie <dnie@redhat.com>
> >>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> >>> A device up can occur at the moment you call register_netdevice(),
> >>> therefore that up call can see the carrier as down and fail or
> >>> similar.  So you really cannot resolve the carrier to be on in this
> >>> way.
> >> True, we need a workqueue to synchronize them.
> > Whatever for?  All you need to do is:
> >
> > 	rtnl_lock();
> > 	register_netdevice();
> > 	netif_carrier_on();
> > 	rtnl_unlock();
> >
> > It would be nice if we could make the current code work with a change i=
n
> > the core, though.
> >
> > Ben.
> >
>=20
> Looks like the link status interrupt may happen during this (after
> netvsc_device_add() was called by rndis_filter_device_add()) without any
> synchronization. This may lead a wrong link status here.

Now I'm confused - if there's a link status interrupt, why are you
setting the carrier on initially?

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-56IykHN8/pSwD5rjO7vl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuY1Tue/yOyVhhEJAQrjCA//biMTbPGxReR86S/jyvSTgRD8v7DzxLeC
BKoqfToZEMsnaNj8PS137rfyKUtdd0NfC/crPv1vox5fMftygNc82i0eoDVZJCDn
t/jKYPSWGXZvOqVAWrV6P0VnwJ6YHh2j9lEpzGOt3VNPpDyZDJ47Cp4dqVVrT5c0
TPWLizma8zQqUvVVE97rn6DHJ+l9a68sydRRZRklkT5HKBV7+S+fhzIPYDGDynqt
F73Dom8OvlFxYr4dRIMM34ULUdINDeUT5G/xeksokJXW2GjeNVDBDhA3lQkZEcOo
XUq2N12oPPMb94U7UXnNntCnxDgPFafdWk2eJx4TriYA3NgWCU+su4bOuBY8tR7l
UIR9aXUv7i52jm6aKNXzPD6cPF5ldDn3+l4fUWyWdgRnmjkvtonx1eSQmaLgO+mg
fM8GzMUBN0Hj3kWylGzPyN/8bTyAaIlny4yfWcGmIZ5F++FLHjLyb+racMgjUoKg
uYaJYny6SoFyM7vc0ecxooXSVK4cOBfPkP1PdeCQ8qaR/yKt1nVEmc/nzCwVZfRS
9pu5IykYRWFha5Guc5qtL4Ka4A2sLa+bBK9h003hlr66tohvX1043/mLqazIJsZK
dCZdDSs4uAsKHnqjAx8Plrv0AaBymPAG23EdkoMo1FPk1OGRzmMGdwkpcglyGDQy
OtrX39qjiLA=
=Z9Dz
-----END PGP SIGNATURE-----

--=-56IykHN8/pSwD5rjO7vl--

--===============4544982949310501754==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============4544982949310501754==--
