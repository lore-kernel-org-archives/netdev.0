From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH for-next 0/8] Add Mellanox mlx5 driver for Connect-IB devices
Date: Wed, 3 Jul 2013 00:15:19 +0300
Message-ID: <CAJZOPZLhQmec_mgnCTbxOmxkgwu35Rp3gQm2w-ZWEJxoojY8iA@mail.gmail.com>
References: <1371384149-24558-1-git-send-email-eli@dev.mellanox.co.il>
	<CAJZOPZ+NQa3CWnw3rZQh2UuwdrNhiwtVSyuk9D9YtwfQQ9e1XA@mail.gmail.com>
	<CAJZOPZKLb9k1xXkTnrtzYKpwrSJDQgBpONUVCp3et36JeaEi-Q@mail.gmail.com>
	<CAL1RGDX5mHj5oVqFhQ4Ssr25jpL4rV2Tv=zXvLOZfwupJ0gqJw@mail.gmail.com>
	<CAL1RGDXsgo9mHteu5MwqnoULd1jqE_LDZ=YfHMH4J=pRZqeLgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDXsgo9mHteu5MwqnoULd1jqE_LDZ=YfHMH4J=pRZqeLgQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 1, 2013 at 9:03 PM, Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote=
:
> In general I don't think overriding the CFLAGS (as you do in the mlx5
> Makefiles) is a good idea, and in particular here your -Wall -Werror
> break the build, at least for my gcc 4.7.3:
>
>   CC      drivers/infiniband/hw/mlx5/qp.o
> /home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c: In
> function =91sq_overhead=92:
> /home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:234:=
2:
> error: case value =914671=92 not in enumerated type =91enum ib_qp_typ=
e=92
> [-Werror=3Dswitch]


Will do both (A) remove the flags added on the driver makefile and (B)
fix the issues pointed by these flags...

[...]

> What is this IB_QPT_REG_UMR stuff anyway?  Shouldn't we strip out all
> that from the mlx5 driver until it's available in the core code?

IB_QPT_REG_UMR is the type of QP used internally by the driver, to do
plain memory registration by verbs consumers. Will apply here a
similar practice to the one done by mlx4 driver to create the proxy
and tunnel QP types  for SRIOV, e.g will define MLX5_IB_QPT_REG_UMR
and use that under driver specific QP creation flags for which we have
the foundations in the IB verbs header file to go and use.

[...]

> /* =3D=3D=3D> this should be passed to the vergbs layer */
> enum {
>         IB_WR_SET_PSV =3D IB_WR_BIND_MW + 10,
>         IB_WR_GET_PSV,
>         IB_WR_CHECK_PSV,
>         IB_WR_RGET_PSV,
>         IB_WR_RCHECK_PSV,
>         IB_WR_UMR,
> };
>
> enum {
>         IB_SEND_UMR_UNREG       =3D IB_SEND_IP_CSUM << 1,
> };
>
> enum ib_latency_class {
>         IB_LATENCY_CLASS_LOW,
>         IB_LATENCY_CLASS_MEDIUM,
>         IB_LATENCY_CLASS_HIGH,
>         IB_LATENCY_CLASS_FAST_PATH
> };
> /* <=3D=3D=3D this should be passed to the vergbs layer */
>
> looks like it shouldn't be in your submission.  (What are "vergbs" an=
yway? :)

Will fix that, basically, will remove things we can get along for now,
e.g unused, even not internally such as IB_WR_YYY_PSV, and internalize
what we do need internally e.g use MLX5_IB_XXX where IB_XXX was used

and "vergbs" is a typo whose fix missed the version submitted...
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
