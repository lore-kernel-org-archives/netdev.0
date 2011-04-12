From: Eric B Munson <emunson@mgebm.net>
Subject: Re: 2.6.39-rc2 boot crash
Date: Tue, 12 Apr 2011 11:59:40 -0400
Message-ID: <20110412155940.GA2598@mgebm.net>
References: <20110406184753.GA7691@mgebm.net>
 <1302115953.8094.217.camel@nimitz>
 <20110406212041.GA2596@mgebm.net>
 <20110406.142157.68145422.davem@davemloft.net>
 <20110406220512.GA2460@mgebm.net>
 <4D9D9AA4.6060304@trash.net>
 <20110411210746.GA2453@mgebm.net>
 <20110411220657.GB5783@ioremap.net>
 <4DA44A73.3060801@trash.net>
 <4DA47247.20700@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="oyUTqETQ0mS9luUI"
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, dave@linux.vnet.ibm.com,
	linux-kernel@vger.kernel.org, gregkh@suse.de,
	NetDev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4DA47247.20700@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 12 Apr 2011, Patrick McHardy wrote:

> On 12.04.2011 14:49, Patrick McHardy wrote:
> > On 12.04.2011 00:06, Evgeniy Polyakov wrote:
> >> Hi.
> >>
> >> On Mon, Apr 11, 2011 at 05:07:47PM -0400, Eric B Munson (emunson@mgebm=
=2Enet) wrote:
> >>>> I can't figure this out, the only thing that should have changed is =
the
> >>>> time the initial PROC_CN_MCAST_LISTEN message is received. Apparently
> >>>> at that point connector is not fully initialized yet. Please post yo=
ur
> >>>> config and the full boot log. Thanks.
> >>>>
> >>>
> >>> I am still seeing this on Linus' tree, is there anything more I can d=
o to help
> >>> track the problem?
> >=20
> > Sorry, I had a hardware failure, I'm back working on this now.
> >=20
> >> Patrick, do you need my assist on this bug?
> >=20
> > Thanks, but I can meanwhile reproduce the problem, so I think I
> > should have a fix soon.
>=20
> I think this patch should fix the problem. Eric, could you please
> give it a try?

This has me up and running again, thanks!

Tested-by: Eric B Munson <emunson@mgebm.net>
>=20
>=20
>=20

> commit ad676e0dbbe8658ce46e192f449689bf3011bdf5
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Tue Apr 12 17:37:04 2011 +0200
>=20
>     connector: fix skb double free in cn_rx_skb()
>    =20
>     When a skb is delivered to a registered callback, cn_call_callback()
>     incorrectly returns -ENODEV after freeing the skb, causing cn_rx_skb()
>     to free the skb a second time.
>    =20
>     Reported-by: Eric B Munson <emunson@mgebm.net>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
>=20
> diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
> index d770058..219d88a 100644
> --- a/drivers/connector/connector.c
> +++ b/drivers/connector/connector.c
> @@ -142,6 +142,7 @@ static int cn_call_callback(struct sk_buff *skb)
>  		cbq->callback(msg, nsp);
>  		kfree_skb(skb);
>  		cn_queue_release_callback(cbq);
> +		err =3D 0;
>  	}
> =20
>  	return err;


--oyUTqETQ0mS9luUI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNpHbsAAoJEH65iIruGRnNlSkH/3ThkQiZk+yG2okW18C89qW7
0gFnNgqSnwxeYTNi93uz5b4JlYj5Ss6EVlnWSIsHkyi3QFWu5i6EJyHK65Hxb+Ys
i+ayB4hgEfFw4s+sRMTn8aunE50Dvc7zvJBwP98IFaQR9tOv6tlKl+SADHsagLmr
WaBsgjIeNBOuhnEvoEc5hIKaxSXOD03FJNIj6O3GpVAz761BrZLnmDOnJK9KYBdY
gPBQt3zj065pZ7UZ7niC4Wc6G5nzvv8RqwrLiIqsBCjY8cOaSa5/71tTgP6+L7Op
6UiYBJD+dk0rgOyBHvP6NgWUzK48zSedNWQqYG/T3DfOc2HlMp90coLKzjGtkX0=
=ux8M
-----END PGP SIGNATURE-----

--oyUTqETQ0mS9luUI--
