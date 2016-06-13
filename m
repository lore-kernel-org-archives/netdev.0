From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v9 11/22] IB/hns: Add IB device registration
Date: Mon, 13 Jun 2016 15:46:38 +0300
Message-ID: <20160613124638.GG5408@leon.nu>
References: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
 <1464795484-77395-12-git-send-email-oulijun@huawei.com>
 <20160609062631.GN3663@leon.nu>
 <575D2E32.8030109@huawei.com>
Reply-To: leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gm5TwAJMO0F2iVRz"
Cc: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <575D2E32.8030109-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--gm5TwAJMO0F2iVRz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jun 12, 2016 at 05:41:06PM +0800, Wei Hu (Xavier) wrote:
>=20
>=20
> On 2016/6/9 14:26, Leon Romanovsky wrote:
> >On Wed, Jun 01, 2016 at 11:37:53PM +0800, Lijun Ou wrote:
> >>This patch registered IB device when loaded, and unregistered
> >>IB device when removed.
> >>
> >>Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >>Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> >>Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >>---
> >>  drivers/infiniband/hw/hns/hns_roce_main.c | 46 ++++++++++++++++++++++=
+++++++++
> >>  1 file changed, 46 insertions(+)
> >>
> >>diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infini=
band/hw/hns/hns_roce_main.c
> >>index 7fb0d34..f179a7f 100644
> >>--- a/drivers/infiniband/hw/hns/hns_roce_main.c
> >>+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
> >>@@ -62,6 +62,41 @@
> >>  #include "hns_roce_device.h"
> >>  #include "hns_roce_icm.h"
> >>+void hns_roce_unregister_device(struct hns_roce_dev *hr_dev)
> >You are not calling to this function in this patch.
> >
> >>+{
> >>+	ib_unregister_device(&hr_dev->ib_dev);
> >>+}
> >>+
> >>+int hns_roce_register_device(struct hns_roce_dev *hr_dev)
> >This function should be static.
> >
> >>+{
> >>+	int ret;
> >>+	struct hns_roce_ib_iboe *iboe =3D NULL;
> >>+	struct ib_device *ib_dev =3D NULL;
> >>+	struct device *dev =3D &hr_dev->pdev->dev;
> >>+
> >>+	iboe =3D &hr_dev->iboe;
> >>+
> >>+	ib_dev =3D &hr_dev->ib_dev;
> >>+	strlcpy(ib_dev->name, "hisi_%d", IB_DEVICE_NAME_MAX);
> >>+
> >>+	ib_dev->owner			=3D THIS_MODULE;
> >>+	ib_dev->node_type		=3D RDMA_NODE_IB_CA;
> >>+	ib_dev->dma_device		=3D dev;
> >>+
> >>+	ib_dev->phys_port_cnt		=3D hr_dev->caps.num_ports;
> >>+	ib_dev->local_dma_lkey		=3D hr_dev->caps.reserved_lkey;
> >>+	ib_dev->num_comp_vectors	=3D hr_dev->caps.num_comp_vectors;
> >>+	ib_dev->uverbs_abi_ver		=3D 1;
> >>+
> >>+	ret =3D ib_register_device(ib_dev, NULL);
> >>+	if (ret) {
> >>+		dev_err(dev, "ib_register_device failed!\n");
> >>+		return ret;
> >>+	}
> >>+
> >>+	return 0;
> >>+}
> >>+
> >>  int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
> >>  {
> >>  	int i;
> >>@@ -363,6 +398,17 @@ static int hns_roce_probe(struct platform_device *=
pdev)
> >>  		goto error_failed_engine_init;
> >>  	}
> >>+	ret =3D hns_roce_register_device(hr_dev);
> >>+	if (ret) {
> >>+		dev_err(dev, "register_device failed!\n");
> >According to the current code, you will print this error together with
> >error line in hns_roce_register_device for the same failure.
> >
> >"ib_register_device failed!"
> >"register_device failed!"
> Hi, leon
>     In this patch [PATCH v9 11/22], there is only one error branch in
> funtion named hns_roce_register_device.
>     In the following patch [PATCH v9 13/22], we add more operation, there
> are more
>         than two error branch in this function as below.

Yes, and in all these error flows you already printed debug messages, your
"register_device failed" print is useless.


--gm5TwAJMO0F2iVRz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXXqsuAAoJEORje4g2clin1i0P/iLtq85f1lAPmRpjoMChRANM
wUqzx9rEyHUQ9k6c4RRO0Bzf2WJMjq81XuRF85vUJebpuC7WAsN6+aGvTQBIRBnq
zWrbMOJTD3EcfzCvf9AQggW7y1DPb4LtFhetY+5DDmdzIHOFeIVaHcUGgTpqCdFl
zA4Rm+nnDdWdV0DkdYAkoQuvU9cOKajv3yjo6hyRnbbjtjkyBwNEpfFzTH7NGsf+
bTaUBt4tUGl6zZDTOvgKLox2Cg57WfduPL7JZFB9IYKvZF9CxFZc1AH52iA0yKUi
uXSvilHhWTD94m4TM47Oq8rJtbo6VAKFyGV2DqrV7rcNcS58ELBLbP/1wMNgLn7n
vkSVk2ZEpTMD7Pc/w6SEx1eYUmi8GuzgIn7eLGUrvZZ8QZrAPyR00iwAhjgzEMrV
j8HoK7HmgaPaqGAYqbGn6HO7flKQfzq7HE7RmChcGh49P0XJwOt8QS/xKdvZh5I2
HodOVqwoQzAAgU74ll6dHl2hW7NY4WeeX1g0v4GYrwBvFsqM+g6NKcqEh13K6VCF
hbEH6OYUKvq4rknTSEejNbv1qycJp75PvlGI7nrm05IRv4wPOttPU0Zdz+ZsGuHM
QcyEJmFXfarg9wcb3OjY+4bVGS6f2PNvU0Z/LFnvcXRZFu3ZT4VnR4ldYZh1boYn
KM9kY7cSap2H8AON3RHn
=0NqX
-----END PGP SIGNATURE-----

--gm5TwAJMO0F2iVRz--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
