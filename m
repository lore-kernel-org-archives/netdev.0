From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: [PATCH 10/14] SIWv2: Transmit path: siw_qp_tx.c
Date: Sat, 18 Jun 2011 19:47:29 +0200
Message-ID: <BANLkTimSqwBK_pEGsydCAEvO=S6WVVzDPQ@mail.gmail.com>
References: <1308228153-22720-1-git-send-email-bmt@zurich.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1308228153-22720-1-git-send-email-bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 16, 2011 at 2:42 PM, Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org> w=
rote:
> ---
> =A0drivers/infiniband/hw/siw/siw_qp_tx.c | 1332 +++++++++++++++++++++=
++++++++++++
> =A01 files changed, 1332 insertions(+), 0 deletions(-)
> =A0create mode 100644 drivers/infiniband/hw/siw/siw_qp_tx.c
>
> diff --git a/drivers/infiniband/hw/siw/siw_qp_tx.c b/drivers/infiniba=
nd/hw/siw/siw_qp_tx.c
[ ... ]
> +/*
> + * Write out iov referencing hdr, data and trailer of current FPDU.
> + * Update transmit state dependent on write return status
> + */
> +static int siw_tx_hdt(struct siw_iwarp_tx *c_tx, struct socket *s)
> +{
> + =A0 =A0 =A0 struct siw_wqe =A0 =A0 =A0 =A0 =A0*wqe =3D c_tx->wqe;
> + =A0 =A0 =A0 struct siw_sge =A0 =A0 =A0 =A0 =A0*sge =3D &wqe->wr.sgl=
=2Esge[c_tx->sge_idx],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *first_=
sge =3D sge;
> + =A0 =A0 =A0 struct siw_mr =A0 =A0 =A0 =A0 =A0 *mr =3D NULL;
> + =A0 =A0 =A0 struct ib_umem_chunk =A0 =A0*chunk =3D c_tx->umem_chunk=
;
> +
> + =A0 =A0 =A0 struct kvec =A0 =A0 =A0 =A0 =A0 =A0 iov[MAX_ARRAY];
> + =A0 =A0 =A0 struct page =A0 =A0 =A0 =A0 =A0 =A0 *page_array[MAX_ARR=
AY];
> + =A0 =A0 =A0 struct msghdr =A0 =A0 =A0 =A0 =A0 msg =3D {.msg_flags =3D=
 MSG_DONTWAIT};
> +
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 seg =3D 0, =
do_crc =3D c_tx->do_crc, is_kva =3D 0, rv;
> + =A0 =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0data_len =3D c_tx->=
bytes_unsent,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hdr_len=
 =3D 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trl_len=
 =3D 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sge_off=
 =3D c_tx->sge_off,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sge_idx=
 =3D c_tx->sge_idx,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg_idx =
=3D c_tx->pg_idx;

Have you run the siw source code through sparse ? Sparse reports the
following for the above:

drivers/infiniband/hw/siw/siw_qp_tx.c:694:1: warning: the frame size
of 1120 bytes is larger than 1024 bytes

I assume that you know that one should be careful with stack
allocations in the kernel ?

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tx_type =3D=3D RDMAP_RDMA_READ_REQ)=
 {

This is what the compiler says about the above statement:

drivers/infiniband/hw/siw/siw_qp_tx.c:1145:15: warning: comparison
between enum siw_wr_opcode and enum rdma_opcode

So how can that statement be correct ?

Bart.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
