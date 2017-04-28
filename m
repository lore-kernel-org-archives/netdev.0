From: Andreas Kemnade <andreas-cLv4Z9ELZ06ZuzBka8ofvg@public.gmane.org>
Subject: Re: [PATCH] net: hso: register netdev later to avoid a race
 condition
Date: Fri, 28 Apr 2017 19:36:29 +0200
Message-ID: <20170428193629.4f72caed@aktux>
References: <1493227600-10102-1-git-send-email-andreas@kemnade.info>
        <20170427084401.GP2823@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/=Sum=iC/oeYlV7_gTKxaNU="; protocol="application/pgp-signature"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
        peter-WaGBZJeGNqdsbIuE7sb01tBPR1lH4CV8@public.gmane.org, hns-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170427084401.GP2823@localhost>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Sig_/=Sum=iC/oeYlV7_gTKxaNU=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 27 Apr 2017 10:44:01 +0200
Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:

> On Wed, Apr 26, 2017 at 07:26:40PM +0200, Andreas Kemnade wrote:
> > If the netdev is accessed before the urbs are initialized,
> > there will be NULL pointer dereferences. That is avoided by
> > registering it when it is fully initialized.
>=20
> > Reported-by: H. Nikolaus Schaller <hns-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org>
> > Signed-off-by: Andreas Kemnade <andreas-cLv4Z9ELZ06ZuzBka8ofvg@public.gmane.org>
> > ---
> >  drivers/net/usb/hso.c | 14 +++++++-------
> >  1 file changed, 7 insertions(+), 7 deletions(-)
> >=20
> > diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> > index 93411a3..00067a0 100644
> > --- a/drivers/net/usb/hso.c
> > +++ b/drivers/net/usb/hso.c
> > @@ -2534,13 +2534,6 @@ static struct hso_device *hso_create_net_device(=
struct usb_interface *interface,
> >  	SET_NETDEV_DEV(net, &interface->dev);
> >  	SET_NETDEV_DEVTYPE(net, &hso_type);
> > =20
> > -	/* registering our net device */
> > -	result =3D register_netdev(net);
> > -	if (result) {
> > -		dev_err(&interface->dev, "Failed to register device\n");
> > -		goto exit;
> > -	}
> > -
> >  	/* start allocating */
> >  	for (i =3D 0; i < MUX_BULK_RX_BUF_COUNT; i++) {
> >  		hso_net->mux_bulk_rx_urb_pool[i] =3D usb_alloc_urb(0, GFP_KERNEL);
> > @@ -2560,6 +2553,13 @@ static struct hso_device *hso_create_net_device(=
struct usb_interface *interface,
> > =20
> >  	add_net_device(hso_dev);
> > =20
> > +	/* registering our net device */
> > +	result =3D register_netdev(net);
> > +	if (result) {
> > +		dev_err(&interface->dev, "Failed to register device\n");
> > +		goto exit;
>=20
> This all looks good, but you should consider cleaning up the error
> handling of this function as a follow-up as we should not be
> deregistering netdevs that have never been registered (e.g. if a
> required endpoint is missing or if registration fails for some reason).
>=20
> But just to be clear, this problem existed also before this change.
>=20
Just to check wether I am understanding this correctly. In your opinion
this patch is good for now. And later when it is applied, there should
be an additional error handling cleanup patch.

Regards,
Andreas

--Sig_/=Sum=iC/oeYlV7_gTKxaNU=
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZA32gAAoJEInxNTv1CwY0bLYQAJLY0YNqpJ0lzRE4XFkdfMSS
ceYIQtWy12HFCeatES0yruYtK/7rvcTnp6HlD2yD+SiDAPtP97Crvua1r1zXMWEF
9b+BCUsS0VkACIQ2k4uDlOOLwXSMnOSGi3goWyHf+Vgf37ykvTne5Cbh5UKGKxFo
ZKz98XEGAxcKCmyGiXBdOJz71k5wNsROOjhasm71NwEKqDDPwLuR/q4TJtsMyawt
quKkfko/lA9+T5mSbZ2GNwl4NVyKEtRe+fVIh4YhXWfiv4FOZHl31hIftU3PfC6M
WLhJ7HRsK2kIb7Cy4hOVUsoGmwBneg0N8dKMSKcyw3GfkYjb79e8zZd7HJGBiV1n
DIaKoaOC+ue7z5FCj/JiJDnNmf6KUIj2AQPFvvx5Uk/ZTJ1EuOatfEag+5DGG30E
EuBRWJQCv7tFu+O5Jb2RyVRN7+/VD7a1oRe69F0PkovcjZGZplMOcsmwMrAXtwzo
qJnfPMRTJDokQP5HKqr4jddJ6lXSRFRPT6eyHJrgTFAtAyzVQT1GNwTcLVxrMvXc
KnWRQaq38YmGZO+RoHvtCPpRjClRUtGJe07DxcV646c1mub/AmKrj0Ses+0GMMOw
lzyvobJaM3t0FOS4iP/KI4q8kKFWWjDEtbI3XgrAlBdC1YEajzbCs4wU5RenCle0
8iWYyqDfAktNH5sjvNhH
=MLpa
-----END PGP SIGNATURE-----

--Sig_/=Sum=iC/oeYlV7_gTKxaNU=--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
