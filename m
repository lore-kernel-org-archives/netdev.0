From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v10 05/22] IB/hns: Add initial profile resource
Date: Fri, 24 Jun 2016 18:10:48 +0300
Message-ID: <20160624151048.GF23995@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-6-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CXFpZVxO6m2Ol4tQ"
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1466087730-54856-6-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--CXFpZVxO6m2Ol4tQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 16, 2016 at 10:35:13PM +0800, Lijun Ou wrote:
> This patch added the operation for cmd, and added some functions
> for initializing eq table and selecting cmd mode.
>=20
> Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
> PATCH v9:
> This fixes the comments given by Leon Romanovsky over the PATCH v8:
>   Link: https://lkml.org/lkml/2016/6/9/65
>=20
> PATCH v8/v7/v6:
> - No change over the PATCH v5
>=20
> PATCH v5:
> - The initial patch which was redesigned based on the second patch
>   in PATCH v4
> ---
> ---
>  drivers/infiniband/hw/hns/hns_roce_common.h | 49 +++++++++++++++++++
>  drivers/infiniband/hw/hns/hns_roce_device.h | 55 ++++++++++++++++++++-
>  drivers/infiniband/hw/hns/hns_roce_hw_v1.c  | 75 +++++++++++++++++++++++=
++++++
>  drivers/infiniband/hw/hns/hns_roce_hw_v1.h  | 36 ++++++++++++++
>  drivers/infiniband/hw/hns/hns_roce_main.c   |  7 +++
>  5 files changed, 221 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/infiniband/hw/hns/hns_roce_common.h
>=20
> diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infini=
band/hw/hns/hns_roce_common.h
> new file mode 100644
> index 0000000..4cc4761
> --- /dev/null
> +++ b/drivers/infiniband/hw/hns/hns_roce_common.h
> @@ -0,0 +1,49 @@
> +/*
> + * Copyright (c) 2016 Hisilicon Limited.
> + *
> + * This software is available to you under a choice of one of two
> + * licenses.  You may choose to be licensed under the terms of the GNU
> + * General Public License (GPL) Version 2, available from the file
> + * COPYING in the main directory of this source tree, or the
> + * OpenIB.org BSD license below:
> + *
> + *     Redistribution and use in source and binary forms, with or
> + *     without modification, are permitted provided that the following
> + *     conditions are met:
> + *
> + *      - Redistributions of source code must retain the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer.
> + *
> + *      - Redistributions in binary form must reproduce the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer in the documentation and/or other materials
> + *        provided with the distribution.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + */
> +
> +#ifndef _HNS_ROCE_COMMON_H
> +#define _HNS_ROCE_COMMON_H
> +
> +#define roce_read(dev, reg)		readl((dev)->reg_base + (reg))
> +
> +/*************ROCEE_REG DEFINITION****************/
> +#define ROCEE_VENDOR_ID_REG			0x0
> +#define ROCEE_VENDOR_PART_ID_REG		0x4
> +
> +#define ROCEE_HW_VERSION_REG			0x8
> +
> +#define ROCEE_SYS_IMAGE_GUID_L_REG		0xC
> +#define ROCEE_SYS_IMAGE_GUID_H_REG		0x10
> +
> +#define ROCEE_ACK_DELAY_REG			0x14
> +
> +#endif /* _HNS_ROCE_COMMON_H */
> diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infini=
band/hw/hns/hns_roce_device.h
> index b857c76..e01ea34 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_device.h
> +++ b/drivers/infiniband/hw/hns/hns_roce_device.h
> @@ -45,6 +45,12 @@
>  #define DRV_NAME "hns_roce"
> =20
>  #define HNS_ROCE_MAX_IRQ_NUM			34
> +
> +#define HNS_ROCE_COMP_VEC_NUM			32
> +
> +#define HNS_ROCE_AEQE_VEC_NUM			1
> +#define HNS_ROCE_AEQE_OF_VEC_NUM		1
> +
>  #define HNS_ROCE_MAX_PORTS			6
> =20
>  struct hns_roce_ib_iboe {
> @@ -53,11 +59,52 @@ struct hns_roce_ib_iboe {
>  };
> =20
>  struct hns_roce_caps {
> -	u8			num_ports;
> +	u64		fw_ver;
> +	u8		num_ports;
> +	int		gid_table_len[HNS_ROCE_MAX_PORTS];
> +	int		pkey_table_len[HNS_ROCE_MAX_PORTS];
> +	int		local_ca_ack_delay;
> +	int		num_uars;
> +	u32		phy_num_uars;
> +	u32		max_sq_sg;	/* 2 */
> +	u32		max_sq_inline;	/* 32 */
> +	u32		max_rq_sg;	/* 2 */
> +	int		num_qps;	/* 256k */
> +	u32		max_wqes;	/* 16k */
> +	u32		max_sq_desc_sz;	/* 64 */
> +	u32		max_rq_desc_sz;	/* 64 */
> +	int		max_qp_init_rdma;
> +	int		max_qp_dest_rdma;
> +	int		sqp_start;
> +	int		num_cqs;
> +	int		max_cqes;
> +	int		reserved_cqs;
> +	int		num_aeq_vectors;	/* 1 */
> +	int		num_comp_vectors;	/* 32 ceq */
> +	int		num_other_vectors;
> +	int		num_mtpts;
> +	u32		num_mtt_segs;
> +	int		reserved_mtts;
> +	int		reserved_mrws;
> +	int		reserved_uars;
> +	int		num_pds;
> +	int		reserved_pds;
> +	u32		mtt_entry_sz;
> +	u32		cq_entry_sz;
> +	u32		page_size_cap;
> +	u32		reserved_lkey;
> +	int		mtpt_entry_sz;
> +	int		qpc_entry_sz;
> +	int		irrl_entry_sz;
> +	int		cqc_entry_sz;
> +	int		aeqe_depth;
> +	int		ceqe_depth[HNS_ROCE_COMP_VEC_NUM];
> +	enum ib_mtu	max_mtu;
>  };

Can you please clean this struct from fields which you don't have?
For example fw_ver.

> =20
>  struct hns_roce_hw {
>  	int (*reset)(struct hns_roce_dev *hr_dev, bool enable);
> +	void (*hw_profile)(struct hns_roce_dev *hr_dev);
>  };
> =20
>  struct hns_roce_dev {
> @@ -70,6 +117,12 @@ struct hns_roce_dev {
>  	u8 __iomem		*reg_base;
>  	struct hns_roce_caps	caps;
> =20
> +	u64                     fw_ver;

Again.

> +	u64			sys_image_guid;
> +	u32                     vendor_id;
> +	u32                     vendor_part_id;
> +	u32                     hw_rev;
> +
>  	int			cmd_mod;
>  	int			loop_idc;
>  	struct hns_roce_hw	*hw;
> diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infinib=
and/hw/hns/hns_roce_hw_v1.c
> index 198be3b..45b4662 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
> +++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
> @@ -35,6 +35,7 @@
>  #include <linux/of_address.h>
>  #include <linux/of_platform.h>
>  #include <linux/platform_device.h>
> +#include "hns_roce_common.h"
>  #include "hns_roce_device.h"
>  #include "hns_roce_hw_v1.h"
> =20
> @@ -67,6 +68,80 @@ int hns_roce_v1_reset(struct hns_roce_dev *hr_dev, boo=
l enable)
>  		return ret;
>  }
> =20
> +void hns_roce_v1_profile(struct hns_roce_dev *hr_dev)
> +{
> +	int i =3D 0;
> +	struct hns_roce_caps *caps =3D &hr_dev->caps;
> +
> +	hr_dev->vendor_id =3D le32_to_cpu(roce_read(hr_dev, ROCEE_VENDOR_ID_REG=
));
> +	hr_dev->vendor_part_id =3D le32_to_cpu(roce_read(hr_dev,
> +					     ROCEE_VENDOR_PART_ID_REG));
> +	hr_dev->hw_rev =3D le32_to_cpu(roce_read(hr_dev, ROCEE_HW_VERSION_REG));
> +	hr_dev->fw_ver =3D 0;
> +
> +	hr_dev->sys_image_guid =3D le32_to_cpu(roce_read(hr_dev,
> +					     ROCEE_SYS_IMAGE_GUID_L_REG)) |
> +				((u64)le32_to_cpu(roce_read(hr_dev,
> +					    ROCEE_SYS_IMAGE_GUID_H_REG)) << 32);
> +
> +	caps->fw_ver		=3D hr_dev->hw_rev;

Which is 0.

> +	caps->num_qps		=3D HNS_ROCE_V1_MAX_QP_NUM;
> +	caps->max_wqes		=3D HNS_ROCE_V1_MAX_WQE_NUM;
> +	caps->num_cqs		=3D HNS_ROCE_V1_MAX_CQ_NUM;
> +	caps->max_cqes		=3D HNS_ROCE_V1_MAX_CQE_NUM;
> +	caps->max_sq_sg		=3D HNS_ROCE_V1_SG_NUM;
> +	caps->max_rq_sg		=3D HNS_ROCE_V1_SG_NUM;
> +	caps->max_sq_inline	=3D HNS_ROCE_V1_INLINE_SIZE;
> +	caps->num_uars		=3D HNS_ROCE_V1_UAR_NUM;
> +	caps->phy_num_uars	=3D HNS_ROCE_V1_PHY_UAR_NUM;
> +	caps->num_aeq_vectors	=3D HNS_ROCE_AEQE_VEC_NUM;
> +	caps->num_comp_vectors	=3D HNS_ROCE_COMP_VEC_NUM;
> +	caps->num_other_vectors	=3D HNS_ROCE_AEQE_OF_VEC_NUM;
> +	caps->num_mtpts		=3D HNS_ROCE_V1_MAX_MTPT_NUM;
> +	caps->num_mtt_segs	=3D HNS_ROCE_V1_MAX_MTT_SEGS;
> +	caps->num_pds		=3D HNS_ROCE_V1_MAX_PD_NUM;
> +	caps->max_qp_init_rdma	=3D HNS_ROCE_V1_MAX_QP_INIT_RDMA;
> +	caps->max_qp_dest_rdma	=3D HNS_ROCE_V1_MAX_QP_DEST_RDMA;
> +	caps->max_sq_desc_sz	=3D HNS_ROCE_V1_MAX_SQ_DESC_SZ;
> +	caps->max_rq_desc_sz	=3D HNS_ROCE_V1_MAX_RQ_DESC_SZ;
> +	caps->qpc_entry_sz	=3D HNS_ROCE_V1_QPC_ENTRY_SIZE;
> +	caps->irrl_entry_sz	=3D HNS_ROCE_V1_IRRL_ENTRY_SIZE;
> +	caps->cqc_entry_sz	=3D HNS_ROCE_V1_CQC_ENTRY_SIZE;
> +	caps->mtpt_entry_sz	=3D HNS_ROCE_V1_MTPT_ENTRY_SIZE;
> +	caps->mtt_entry_sz	=3D HNS_ROCE_V1_MTT_ENTRY_SIZE;
> +	caps->cq_entry_sz	=3D HNS_ROCE_V1_CQE_ENTRY_SIZE;
> +	caps->page_size_cap	=3D HNS_ROCE_V1_PAGE_SIZE_SUPPORT;
> +	caps->sqp_start		=3D 0;
> +	caps->reserved_lkey	=3D 0;
> +	caps->reserved_pds	=3D 0;
> +	caps->reserved_mrws	=3D 1;
> +	caps->reserved_mtts	=3D 0;
> +	caps->reserved_uars	=3D 0;
> +	caps->reserved_cqs	=3D 0;
> +
> +	for (i =3D 0; i < caps->num_ports; i++)
> +		caps->pkey_table_len[i] =3D 1;
> +
> +	for (i =3D 0; i < caps->num_ports; i++) {
> +		/* Six ports shared 16 GID in v1 engine */
> +		if (i >=3D (HNS_ROCE_V1_GID_NUM % caps->num_ports))
> +			caps->gid_table_len[i] =3D HNS_ROCE_V1_GID_NUM /
> +						 caps->num_ports;
> +		else
> +			caps->gid_table_len[i] =3D HNS_ROCE_V1_GID_NUM /
> +						 caps->num_ports + 1;
> +	}
> +
> +	for (i =3D 0; i < caps->num_comp_vectors; i++)
> +		caps->ceqe_depth[i] =3D HNS_ROCE_V1_NUM_COMP_EQE;
> +
> +	caps->aeqe_depth =3D HNS_ROCE_V1_NUM_ASYNC_EQE;
> +	caps->local_ca_ack_delay =3D le32_to_cpu(roce_read(hr_dev,
> +							 ROCEE_ACK_DELAY_REG));
> +	caps->max_mtu =3D IB_MTU_2048;
> +}
> +
>  struct hns_roce_hw hns_roce_hw_v1 =3D {
>  	.reset =3D hns_roce_v1_reset,
> +	.hw_profile =3D hns_roce_v1_profile,
>  };
> diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infinib=
and/hw/hns/hns_roce_hw_v1.h
> index a8c0c1d..31a9a6d 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
> +++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
> @@ -33,6 +33,42 @@
>  #ifndef _HNS_ROCE_HW_V1_H
>  #define _HNS_ROCE_HW_V1_H
> =20
> +#define HNS_ROCE_V1_MAX_PD_NUM				0x8000
> +#define HNS_ROCE_V1_MAX_CQ_NUM				0x10000
> +#define HNS_ROCE_V1_MAX_CQE_NUM				0x8000
> +
> +#define HNS_ROCE_V1_MAX_QP_NUM				0x40000
> +#define HNS_ROCE_V1_MAX_WQE_NUM				0x4000
> +
> +#define HNS_ROCE_V1_MAX_MTPT_NUM			0x80000
> +
> +#define HNS_ROCE_V1_MAX_MTT_SEGS			0x100000
> +
> +#define HNS_ROCE_V1_MAX_QP_INIT_RDMA			128
> +#define HNS_ROCE_V1_MAX_QP_DEST_RDMA			128
> +
> +#define HNS_ROCE_V1_MAX_SQ_DESC_SZ			64
> +#define HNS_ROCE_V1_MAX_RQ_DESC_SZ			64
> +#define HNS_ROCE_V1_SG_NUM				2
> +#define HNS_ROCE_V1_INLINE_SIZE				32
> +
> +#define HNS_ROCE_V1_UAR_NUM				256
> +#define HNS_ROCE_V1_PHY_UAR_NUM				8
> +
> +#define HNS_ROCE_V1_GID_NUM				16
> +
> +#define HNS_ROCE_V1_NUM_COMP_EQE			0x8000
> +#define HNS_ROCE_V1_NUM_ASYNC_EQE			0x400
> +
> +#define HNS_ROCE_V1_QPC_ENTRY_SIZE			256
> +#define HNS_ROCE_V1_IRRL_ENTRY_SIZE			8
> +#define HNS_ROCE_V1_CQC_ENTRY_SIZE			64
> +#define HNS_ROCE_V1_MTPT_ENTRY_SIZE			64
> +#define HNS_ROCE_V1_MTT_ENTRY_SIZE			64
> +
> +#define HNS_ROCE_V1_CQE_ENTRY_SIZE			32
> +#define HNS_ROCE_V1_PAGE_SIZE_SUPPORT			0xFFFFF000
> +

Please fix indentation

>  #define SLEEP_TIME_INTERVAL				20
> =20
>  extern int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool e=
nable);
> diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniba=
nd/hw/hns/hns_roce_main.c
> index d5ccce2..b487b57 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_main.c
> +++ b/drivers/infiniband/hw/hns/hns_roce_main.c
> @@ -125,6 +125,11 @@ static int hns_roce_engine_reset(struct hns_roce_dev=
 *hr_dev, bool enable)
>  	return hr_dev->hw->reset(hr_dev, enable);
>  }
> =20
> +static void hns_roce_profile_init(struct hns_roce_dev *hr_dev)

No need to create function for one line of code which will be called
once only.

> +{
> +	hr_dev->hw->hw_profile(hr_dev);
> +}
> +
>  /**
>  * hns_roce_probe - RoCE driver entrance
>  * @pdev: pointer to platform device
> @@ -169,6 +174,8 @@ static int hns_roce_probe(struct platform_device *pde=
v)
>  		goto error_failed_get_cfg;
>  	}
> =20
> +	hns_roce_profile_init(hr_dev);
> +
>  error_failed_get_cfg:
>  	ib_dealloc_device(&hr_dev->ib_dev);
> =20
> --=20
> 1.9.1
>=20

--CXFpZVxO6m2Ol4tQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXbU14AAoJEORje4g2clinyxUQALhlC6Th/Ii48OjEHoCvVdZ7
y2+pzCKbMxvzRIX4mIgg7CNX6JeWy8Bcd8Kwzob7GssgxfgZxNc7+j04dYIR1sze
FM5i4y9Z1Gl8FyeDzfgZEnwp+8zhJ+5B7UKvLk/QMePLOo75aiFWU/cpV0wI2nVf
HOLCvx9nW7Z6Bm8Yb5nmX4BW8LU3KC/JjkINmeziorCMxUS0A9oLQadm/E05ODdX
5HCfZmPyX4/kOmPNJIHWifZarvHVKkIYrfA+J0SMG583Aesp+w8ux85ElYmH+5Ru
m0ssmej5b7d5GSNAmnP3PzxKHxWk14CZmFg1oJ3DzuNL2fc4SY8Ele+xQuButQtL
MG6VlRU5skEEmlb1clDlY+8dGYLwZX2JP89rRoPLkh9myGuV/FFQjDUfvzo3yiKo
D2jW0TOTo5/H5+pPWLdJ1KuWET5vUbPi+zixsR2bdPJFW3un2RHt+P2C4qriO2pN
qpcqvwcwV82CxjXH+Lk2oH2zmxO9GGOETF3jLEuLMUiRNGPjX53HRJVwklJLhaT0
pLNuVAgCqivTil0WZabI5zeHC/eNe1qSDOVGLX9SbYNtm6PweLlqptn8JrDEf2Cf
Jra7PBi8CikNosZG037fpKmHhTBNdBYK+lohFm7ZjbTUeyokyeJHh//eIuUCr7wY
Uxsh8Skeq/aUBWklg/EQ
=F0vc
-----END PGP SIGNATURE-----

--CXFpZVxO6m2Ol4tQ--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
