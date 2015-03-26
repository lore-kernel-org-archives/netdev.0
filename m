From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2 RESEND] IB/Verbs: Use helpers to refine the checking
 on transport and link layer
Date: Thu, 26 Mar 2015 12:27:38 -0400
Message-ID: <1427387258.21101.124.camel@redhat.com>
References: <5512CFB0.1050108@profitbricks.com>
	 <1427378940.21101.100.camel@redhat.com> <55142DFD.2060100@profitbricks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-J/Y4N0HcTdODZ8Wk9AOY"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Yan Burman <yanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Dan Carpenter <dan.carpenter@o
To: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55142DFD.2060100-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-J/Y4N0HcTdODZ8Wk9AOY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-03-26 at 17:04 +0100, Michael Wang wrote:
> Hi, Doug
>=20
> Thanks for the excellent comments :-)
>=20
> On 03/26/2015 03:09 PM, Doug Ledford wrote:
> > On Wed, 2015-03-25 at 16:09 +0100, Michael Wang wrote:
> >> [snip]
> >>
> > [snip]
> >
> > So, I would suggest that we fix things up thusly:
> >
> > enum transport {
> > 	TRANSPORT_IB=3D1,
> > 	TRANSPORT_IWARP=3D2,
> > 	TRANSPORT_ROCE=3D4,
> > 	TRANSPORT_OPA=3D8,
> > 	TRANSPORT_USNIC=3D10,
> > };
> >
> > #define HAS_SA(ibdev) ((ibdev)->transport & (TRANSPORT_IB|TRANSPORT_OPA=
))
> > #define HAS_JUMBO_SA(ibdev) ((ibdev)->transport & TRANSPORT_OPA))
> >
> > or possibly
> >
> > static bool ib_dev_has_sa(struct ibv_device *ibdev)
> > {
> > 	return ibdev->transport & (TRANSPORT_IB | TRANSPORT_OPA);
> > }
>=20
> The idea sounds interesting, and here my silly questions come :-P
>=20
> So are you suggesting that we add a new bitmask 'transport' into 'struct =
ib_device'
> in kernel, and setup it at very beginning?
>=20
> Few more questions here is:
> 1. when to setup? (maybe inside ib_register_device() before doing client-=
>add() callback?)

I don't think "we" can set it up here.  The driver's have to set it up.
After all, the mlx4 driver will have to decide for itself what the port
transport is and tell us, we can't tell it.

> 2. how to setup? (still infer from the transport and link layer like we c=
urrently do?)

Find each point in each driver where they currently set the link layer
and transport fields today, and replace that with setting the new
transport bitmask instead.

> 3. in case if a device has ports with different link layer type (please c=
orrect
>     me if this will never happen), then only one bitmask may not be enoug=
h to
>     present the transport of all the ports? (maybe create a bitmask per p=
ort?)

Correct, a bitmask per port.  And we can remove the existing transport
and link layer elements of the struct and replace it with just the new
transport.  Then, whenever we need to copy a struct to user space, we
have a helper that looks something like this:

static void inline ib_set_user_transport(struct ib_device *ibdev,
					 struct user_ibv_device *uibdev)
{
	switch(ibdev->port[port]->transport) {
	case TRANSPORT_IB:
	case TRANSPORT_OPA:
		uibdev->port[port]->link_layer =3D INFINIBAND;
		uibdev->port[port]->transport =3D INFINIBAND;
		break;
	case TRANSPORT_IWARP:
		uibdev->port[port]->link_layer =3D INFINIBAND;
		uibdev->port[port]->transport =3D IWARP;
		break;
	case TRANSPORT_ROCE:
		uibdev->port[port]->link_layer =3D ETHERNET;
		uibdev->port[port]->transport =3D INFINIBAND;
		break;
	case TRANSPORT_USNIC:
		uibdev->port[port]->link_layer =3D ETHERNET;
		uibdev->port[port]->transport =3D <whatever USNIC uses today>;
		break;
	default:
		pr_err(ibdev, "unknown transport type %x\n",
		       ibdev->port[port]->transport);
	}
}

That preserves the user space ABI and all user programs keep working,
while we update to an internal representation that makes more sense for
how things have evolved.

> Regards,
> Michael Wang
>=20
> >
> > If we do this, then the only thing we have to fix up to preserve ABI
> > with user space is to make sure that any time we export an ibv_device
> > struct and any time we import the same, we convert from our new interna=
l
> > representation to the old representation that user space expects.  And
> > we also need to make a few changes in the sysfs code to display the
> > properties as things expect.  But, that would allow us to fix up what I
> > see as a problem right now, which is that we hide the information we
> > need to know what sort of device we are working on in two different
> > fields: the transport and the link layer.  Instead, just use one field
> > with enough variants that we can store all of the relevant information
> > we need in that one field.  This has the benefit that any comparisons
> > that happen in hot paths will now always be a single bitwise comparison
> > and will no longer need to hit two separate variables for two separate
> > compares.
> >
> >
> >
>=20


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--=-J/Y4N0HcTdODZ8Wk9AOY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVFDN6AAoJELgmozMOVy/d9q8QAIT8viYhax0bYOOcoCIek2lf
hjtQ06I1eYd6IZTO57587qSKOxuuV7Yvd0Y+f5/sDyPzWmhsLRlyYTrJZGC1WYx1
LGOdsX8UZEvuYuQpNedbnT79vb64NSqA8BOl3wcZNLtd0ViGVsa0KWzTOdjGGimg
lZx18WYfeLS3NJfcagt22/3NuyWsCiuxwyLKmz0248Euc3W+9MFyoXv25zFElfPr
Vq6LaTC+iwvnRJh3S7czA4MEUdyiBelgv2y2UMBcKrASKjyd7Is+0rwUhAvPAAeZ
HdeALg8aLI4YLWLjtF+n2ZTondYr0GXU+ZsDGR5kZsEkvdlU//v1mwd77OabTPiy
SjAuLr04GYKZ5Vc5wp7K9QbgpKgjhGyjq/MJHMG9lGaA4nfvpqsRPM8BU+/XwPUK
cgZ92FSHiEFsU/wuQCIPRgCSo2zfJLQVywCyj8ROk2OJqDGXJs+F403tMUcfkNOT
LAEFR7E8ngrWiT+lZG7WSB8iAD9wgG17MG8VELiz6yK9CnlTfPVRaMr5R7K9xyqV
ugtUyCfq6W+UzKmFsWr6sJoIKZr9pMPaL1TK9HVixEHVlMflu65tl7c2E/Hels8n
kMy0T5xKT5SkqyRkLq/5QjD25fJYaqbHOhNth6QtFJ8+Ix/WCIDx5BtazR0UTrE+
tQNfXFEEGrDo+lmW93j1
=R0Bs
-----END PGP SIGNATURE-----

--=-J/Y4N0HcTdODZ8Wk9AOY--

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
