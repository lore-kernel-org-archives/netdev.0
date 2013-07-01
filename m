From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH for-next 0/8] Add Mellanox mlx5 driver for Connect-IB devices
Date: Mon, 1 Jul 2013 11:03:48 -0700
Message-ID: <CAL1RGDXsgo9mHteu5MwqnoULd1jqE_LDZ=YfHMH4J=pRZqeLgQ@mail.gmail.com>
References: <1371384149-24558-1-git-send-email-eli@dev.mellanox.co.il>
 <CAJZOPZ+NQa3CWnw3rZQh2UuwdrNhiwtVSyuk9D9YtwfQQ9e1XA@mail.gmail.com>
 <CAJZOPZKLb9k1xXkTnrtzYKpwrSJDQgBpONUVCp3et36JeaEi-Q@mail.gmail.com> <CAL1RGDX5mHj5oVqFhQ4Ssr25jpL4rV2Tv=zXvLOZfwupJ0gqJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDX5mHj5oVqFhQ4Ssr25jpL4rV2Tv=zXvLOZfwupJ0gqJw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In general I don't think overriding the CFLAGS (as you do in the mlx5
Makefiles) is a good idea, and in particular here your -Wall -Werror
break the build, at least for my gcc 4.7.3:

  CC      drivers/infiniband/hw/mlx5/qp.o
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c: In
function =91sq_overhead=92:
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:234:2:
error: case value =914671=92 not in enumerated type =91enum ib_qp_type=92
[-Werror=3Dswitch]
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c: In
function =91qp_has_rq=92:
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:334:20=
:
error: comparison between =91enum ib_qp_type=92 and =91enum <anonymous>=
=92
[-Werror=3Denum-compare]
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c: In
function =91to_mlx5_st=92:
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:464:2:
error: case value =914671=92 not in enumerated type =91enum ib_qp_type=92
[-Werror=3Dswitch]
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c: In
function =91create_kernel_qp=92:
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:613:25=
:
error: comparison between =91enum ib_qp_type=92 and =91enum <anonymous>=
=92
[-Werror=3Denum-compare]
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c: In
function =91create_qp_common=92:
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:815:25=
:
error: comparison between =91enum ib_qp_type=92 and =91enum <anonymous>=
=92
[-Werror=3Denum-compare]
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c: In
function =91get_cqs=92:
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:975:2:
error: case value =914671=92 not in enumerated type =91enum ib_qp_type=92
[-Werror=3Dswitch]
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c: In
function =91ib_qp_type_str=92:
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:1064:2=
:
error: case value =914671=92 not in enumerated type =91enum ib_qp_type=92
[-Werror=3Dswitch]
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c: In
function =91mlx5_ib_create_qp=92:
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:1086:2=
6:
error: comparison between =91enum ib_qp_type=92 and =91enum <anonymous>=
=92
[-Werror=3Denum-compare]
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:1113:2=
:
error: case value =914671=92 not in enumerated type =91enum ib_qp_type=92
[-Werror=3Dswitch]
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c: In
function =91__mlx5_ib_modify_qp=92:
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:1452:2=
0:
error: comparison between =91enum ib_qp_type=92 and =91enum <anonymous>=
=92
[-Werror=3Denum-compare]
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c: In
function =91mlx5_ib_modify_qp=92:
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:1615:2=
0:
error: comparison between =91enum ib_qp_type=92 and =91enum <anonymous>=
=92
[-Werror=3Denum-compare]
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c: In
function =91mlx5_ib_post_send=92:
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:2166:1=
9:
error: comparison between =91enum ib_wr_opcode=92 and =91enum <anonymou=
s>=92
[-Werror=3Denum-compare]
/home/roland/Src/linux-merge.git/drivers/infiniband/hw/mlx5/qp.c:2165:3=
:
error: case value =914671=92 not in enumerated type =91enum ib_qp_type=92
[-Werror=3Dswitch]


What is this IB_QPT_REG_UMR stuff anyway?  Shouldn't we strip out all
that from the mlx5 driver until it's available in the core code?
Especially stuff like

/*
 * we do not expose this yet so we use a value out of range */
enum {
        IB_QPT_REG_UMR =3D IB_QPT_MAX + 0x1234,
};

/* =3D=3D=3D> this should be passed to the vergbs layer */
enum {
        IB_WR_SET_PSV =3D IB_WR_BIND_MW + 10,
        IB_WR_GET_PSV,
        IB_WR_CHECK_PSV,
        IB_WR_RGET_PSV,
        IB_WR_RCHECK_PSV,
        IB_WR_UMR,
};

enum {
        IB_SEND_UMR_UNREG       =3D IB_SEND_IP_CSUM << 1,
};

enum ib_latency_class {
        IB_LATENCY_CLASS_LOW,
        IB_LATENCY_CLASS_MEDIUM,
        IB_LATENCY_CLASS_HIGH,
        IB_LATENCY_CLASS_FAST_PATH
};
/* <=3D=3D=3D this should be passed to the vergbs layer */

looks like it shouldn't be in your submission.  (What are "vergbs" anyw=
ay? :)
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
