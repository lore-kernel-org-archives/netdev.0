From: "Kalderon, Michal" <Michal.Kalderon@cavium.com>
Subject: Re: [PATCH net-next] qed: Set error code for allocation failures
Date: Sun, 29 Oct 2017 07:50:06 +0000
Message-ID: <CY1PR0701MB201234A30578ED57BA9EAE6E88580@CY1PR0701MB2012.namprd07.prod.outlook.com>
References: <20171027064020.aq52ue4kfp5htrb5@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Dept-Eng Everest Linux L2 <Dept-EngEverestLinuxL2@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027064020.aq52ue4kfp5htrb5@mwanda>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Sent: Friday, October 27, 2017 9:40 AM

> There are several places where we accidentally return success when
> kcalloc() fails.
>=20
> Fixes: fcb39f6c10b2 ("qed: Add mpa buffer descriptors for storing and pro=
cessing mpa fpdus")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/et=
hernet/qlogic/qed/qed_iwarp.c
> index 409041eab189..6366f2ef82b7 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
> +++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
> @@ -2585,7 +2585,7 @@ qed_iwarp_ll2_start(struct qed_hwfn *p_hwfn,
>         struct qed_ll2_cbs cbs;
>         u32 mpa_buff_size;
>         u16 n_ooo_bufs;
> -       int rc =3D 0;
> +       int rc;
>         int i;
>=20
>         iwarp_info =3D &p_hwfn->p_rdma_info->iwarp;
> @@ -2696,6 +2696,7 @@ qed_iwarp_ll2_start(struct qed_hwfn *p_hwfn,
>         if (rc)
>                goto err;
>=20
> +       rc =3D -ENOMEM;
>         iwarp_info->partial_fpdus =3D kcalloc((u16)p_hwfn->p_rdma_info->n=
um_qps,
>                                             sizeof(*iwarp_info->partial_f=
pdus),
>                                             GFP_KERNEL);
> @@ -2724,7 +2725,7 @@ qed_iwarp_ll2_start(struct qed_hwfn *p_hwfn,
>         for (i =3D 0; i < data.input.rx_num_desc; i++)
>                 list_add_tail(&iwarp_info->mpa_bufs[i].list_entry,
>                               &iwarp_info->mpa_buf_list);
> -       return rc;
> +       return 0;
>  err:
>         qed_iwarp_ll2_stop(p_hwfn, p_ptt);

Thanks Dan,
Acked-by: Michal Kalderon <michal.kalderon@cavium.com>=
