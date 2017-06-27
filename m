From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC 15/19] RDMA/qedr: Add iWARP support in existing verbs.
Date: Tue, 27 Jun 2017 08:27:03 +0300
Message-ID: <20170627052703.GL1248@mtr-leonro.local>
References: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
 <1498500429-22557-16-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="rxd0khGtqYUbFQFd"
Cc: ram.amrani@cavium.com, yuval.mintz@cavium.com,
        ariel.elior@cavium.com, davem@davemloft.net,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        dledford@redhat.com
To: Michal Kalderon <Michal.Kalderon@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:38880 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751312AbdF0F1K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 01:27:10 -0400
Content-Disposition: inline
In-Reply-To: <1498500429-22557-16-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--rxd0khGtqYUbFQFd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jun 26, 2017 at 09:07:05PM +0300, Michal Kalderon wrote:
> Make slight modifications to common RoCE/iWARP code.
> Add additional doorbell for iWARP post_send.
> iWARP QP pbl is allocated in qed and not in qedr.
>
> Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
> Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
>
> ---
>  drivers/infiniband/hw/qedr/qedr.h  |   3 +
>  drivers/infiniband/hw/qedr/verbs.c | 171 +++++++++++++++++++++++++++++--------
>  2 files changed, 139 insertions(+), 35 deletions(-)
>
> diff --git a/drivers/infiniband/hw/qedr/qedr.h b/drivers/infiniband/hw/qedr/qedr.h
> index c52fde0..0c0a39a 100644
> --- a/drivers/infiniband/hw/qedr/qedr.h
> +++ b/drivers/infiniband/hw/qedr/qedr.h
> @@ -319,6 +319,9 @@ struct qedr_qp_hwq_info {
>  	/* DB */
>  	void __iomem *db;
>  	union db_prod32 db_data;
> +
> +	void __iomem *iwarp_db2;
> +	union db_prod32 iwarp_db2_data;

Why do you need two doorbells?

>  };

--rxd0khGtqYUbFQFd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllR7KcACgkQ5GN7iDZy
WKd5FA/+Ix/3PmSx3LAbLGdXQPauJ0j3hCTJqpyWQlL9tLltgu9FELQtenRzCGTi
CmbLi8OKnEheaTp/njjfWxJ7tQBX2aLgIklfQExiSsoh/Mma2Fd2f90gjAqne+B6
IDUIzIQwpuQ4SBP9gZPG78EsRGR7gwLwtqaK7F/mf/Gv6WDisWWzpR1NwCUdqzG9
r47xWwsaUPMmwo6wU9E9NF7mET8yjmx/xBq4w7EA5+gZNTiUZvkCV7/zn0isAYtw
sMDm8GIfukDhNH8gBVy99C+HnOmJNCXpJCBuovtAVvTOrEZqhHpG7LcY2DBx0gOI
XtVC955oLNJrSIT8yLEf0cnHo/G5+mDjHDp8MOpg+4ABN+ftZyCnxro3h01Rvp+7
bFp1NNN5KLfNAwpnCbxiSPibOwLquetM+Fqwjb91J8GlkBvDZ9BqmM8rNdX8BYJb
bnOZuDpP/e1vq35RuULj//QNiz6xZ16WlCPA0ZI6moIOImU4FpnmEuMIdLmGENyX
DwTZrXdh0NoQhZgSP0vuohAbkSbJ1e4hysuHP5/AXX+cA6Ob7SK7wlFLbNLHv6+4
afi7qesoD0T9JawT5xyZzWeFRo7c3XCnEABGTwdsaxFvTw6K5dtV6JA0/O2AMVUW
IDqoAYYKU2usU7B770o70FCS1bnZj/5oG+n4FG2VLE1MkGSCNqE=
=zj3g
-----END PGP SIGNATURE-----

--rxd0khGtqYUbFQFd--
