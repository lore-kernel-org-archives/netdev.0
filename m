From: Yann Droneaud <ydroneaud@opteya.com>
Subject: Re: [PATCH 1/4] iw_cxgb4: Detect Ing. Padding Boundary at run-time
Date: Sun, 13 Jul 2014 13:48:39 +0200
Message-ID: <1405252119.32637.16.camel@localhost.localdomain>
References: <1405091662-5270-1-git-send-email-hariprasad@chelsio.com>
	 <1405091662-5270-2-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	davem@davemloft.net, roland@purestorage.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ou.quest-ce.net ([195.154.187.82]:45688 "EHLO ou.quest-ce.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753396AbaGMMTU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jul 2014 08:19:20 -0400
In-Reply-To: <1405091662-5270-2-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Le vendredi 11 juillet 2014 =C3=A0 20:44 +0530, Hariprasad Shenai a =C3=
=A9crit :
> Updates iw_cxgb4 to determine the Ingress Padding Boundary from
> cxgb4_lld_info, and take subsequent actions.
>=20
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
>  drivers/infiniband/hw/cxgb4/cq.c                |    4 ++--
>  drivers/infiniband/hw/cxgb4/device.c            |   21 +++++++++++++=
++++++++
>  drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |   12 ++++++++++++
>  drivers/infiniband/hw/cxgb4/provider.c          |    4 ++--
>  drivers/infiniband/hw/cxgb4/qp.c                |   10 ++++++----
>  drivers/infiniband/hw/cxgb4/t4.h                |    8 --------
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    2 ++
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    2 ++
>  8 files changed, 47 insertions(+), 16 deletions(-)
>=20

[...]

> diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniban=
d/hw/cxgb4/device.c
> index dd93aad..95e6c6c 100644
> --- a/drivers/infiniband/hw/cxgb4/device.c
> +++ b/drivers/infiniband/hw/cxgb4/device.c
> @@ -768,6 +768,27 @@ static struct c4iw_dev *c4iw_alloc(const struct =
cxgb4_lld_info *infop)
>  	}
>  	devp->rdev.lldi =3D *infop;
> =20
> +	/* init various hw-queue params based on lld info */
> +	pr_info("%s: ing. padding boundary is %d, egrsstatuspagesize =3D %d=
\n",
> +		__func__, devp->rdev.lldi.sge_ingpadboundary,
> +		devp->rdev.lldi.sge_egrstatuspagesize);

Is this really needed ?

Use dev_info() or perhaps dev_dbg() instead of pr_info().

Regards.

--=20
Yann Droneaud
OPTEYA
