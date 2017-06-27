From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC 01/19] qed: Introduce iWARP personality
Date: Tue, 27 Jun 2017 08:36:35 +0300
Message-ID: <20170627053635.GM1248@mtr-leonro.local>
References: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
 <1498500429-22557-2-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="Ahst0DKxuyFxAqHk"
Cc: ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        ariel.elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1498500429-22557-2-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--Ahst0DKxuyFxAqHk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jun 26, 2017 at 09:06:51PM +0300, Michal Kalderon wrote:
> iWARP personality introduced the need for differentiating in several
> places in the code whether we are RoCE, iWARP or either. This
> leads to introducing new macros for querying the personality.
>
> Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>
> ---
>  drivers/net/ethernet/qlogic/qed/qed.h      | 26 +++++++++++++++++++++++---
>  drivers/net/ethernet/qlogic/qed/qed_cxt.c  |  8 ++++----
>  drivers/net/ethernet/qlogic/qed/qed_dev.c  | 12 +++++-------
>  drivers/net/ethernet/qlogic/qed/qed_l2.c   |  3 +--
>  drivers/net/ethernet/qlogic/qed/qed_ll2.c  |  2 +-
>  drivers/net/ethernet/qlogic/qed/qed_main.c | 17 ++++++++---------
>  include/linux/qed/common_hsi.h             |  2 +-
>  7 files changed, 43 insertions(+), 27 deletions(-)

I see that these changes are in Ethernet part of your driver, but for
RDMA part, there are already available inline functions:
rdma_protocol_iwarp, rdma_protocol_roce.

Please avoid introducing new IS_IWARP/IS_ROCE macros and the decision
should be taken on port level and not on device, despite the fact that
probably your ib_device has only one port.

Thanks

--Ahst0DKxuyFxAqHk
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllR7uMACgkQ5GN7iDZy
WKcs9hAAzRctvpDcxhSkZ9y/PWccUW2HvMf81m41OdxDQS16YH8REK7DdZv3eXCB
Ijjntur31VtIy5+iO1Y7aAqS01l2KIKzh/nh3e+5T6XONtlXs/2HK+qMyB4MtDqK
TIpLEPKz+azTRisSYulpccrh0U7uAgQV23MNlFhryE/ghW/IQ+XjIgEAHoTjF7cC
nPPamSPUmywx7PsC9hIjvdX1cuXyMkLIUmqIlAsP5K7fLQklhcwW+6Lr9YDbEqIi
qFHZ0b96FWazDd7QRiKhaPIKzXtdRV3ZxQaFtmRfesE8iF5q2YFN7FMQPtOITUJY
dtkOY5yUDg3d9323o5fApdV7iDT+874w3GHIbDUI8rLH++4MdHnPgh95cfxWon1V
XMq7f0ZxGOKWwcgG1n74bzNrUZ14ubUCpFMB0ILZkpPuj0LXIa6pX0bpUH5+9AhU
YGghQhSriUaqBSVcEJQBsE73UTGH3VTEwitU6tRPPiTGMkwIkXSu94jvqFd3u5B7
Psm5L3mug9JzfOgKUOvcYHcKTp97KlFplrJDmF3VdP0tpvjRs2/5HgWrSx267Ig7
wje0t63TVmUMdcnvhJN/Im1gkxLxDE3PC1rBBeeEM49Qomv3Dk0/CVfQmaU/FK8O
2GJMLVxwdtOstFpIfUBTjlXMCSkYSeYfDvh5kUWXqk+KbAdaogo=
=MopR
-----END PGP SIGNATURE-----

--Ahst0DKxuyFxAqHk--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
