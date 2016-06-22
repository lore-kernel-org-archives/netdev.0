From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v10 06/22] IB/hns: Add initial cmd operation
Date: Wed, 22 Jun 2016 07:54:50 +0300
Message-ID: <20160622045450.GC9762@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-7-git-send-email-oulijun@huawei.com>
 <20160620133310.GB4526@leon.nu>
 <57691C0B.8090509@huawei.com>
 <20160621112808.GA9762@leon.nu>
 <57693AC4.1070306@huawei.com>
Reply-To: leon@kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5G06lTa6Jq83wMTw"
Cc: Lijun Ou <oulijun@huawei.com>, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jiri@mellanox.com, ogerlitz@mellanox.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gongyangming@huawei.com,
	xiaokun@huawei.com, tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	charles.chenxin@huawei.com, linuxarm@huawei.com
To: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57693AC4.1070306@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--5G06lTa6Jq83wMTw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 21, 2016 at 09:01:57PM +0800, Wei Hu (Xavier) wrote:
>=20
>=20
> On 2016/6/21 19:28, Leon Romanovsky wrote:
> >On Tue, Jun 21, 2016 at 06:50:51PM +0800, Wei Hu (Xavier) wrote:
> >>
> >>On 2016/6/20 21:33, Leon Romanovsky wrote:
> >>>On Thu, Jun 16, 2016 at 10:35:14PM +0800, Lijun Ou wrote:
> >>>>This patch added the operation for cmd, and added some functions
> >>>>for initializing eq table and selecting cmd mode.
> >>>>
> >>>>Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
> >>>>Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
> >>>>Signed-off-by: Lijun Ou <oulijun@huawei.com>
> >>>>---
> >>>>PATCH v9/v8/v7/v6:
> >>>>- No change over the PATCH v5
> >>>>
> >>>>PATCH v5:
> >>>>- The initial patch which was redesigned based on the second patch
> >>>>   in PATCH v4
> >>>>---
> >>><...>
> >>>
> >>>>+#define CMD_MAX_NUM		32
> >>>>+
> >>>>+int hns_roce_cmd_init(struct hns_roce_dev *hr_dev)
> >>>>+{
> >>>>+	struct device *dev =3D &hr_dev->pdev->dev;
> >>>>+
> >>>>+	mutex_init(&hr_dev->cmd.hcr_mutex);
> >>>>+	sema_init(&hr_dev->cmd.poll_sem, 1);
> >>>>+	hr_dev->cmd.use_events =3D 0;
> >>>>+	hr_dev->cmd.toggle =3D 1;
> >>>>+	hr_dev->cmd.max_cmds =3D CMD_MAX_NUM;
> >>><...>
> >>>
> >>>>+	for (hr_cmd->token_mask =3D 1; hr_cmd->token_mask < hr_cmd->max_cmd=
s;
> >>>>+	     hr_cmd->token_mask <<=3D 1)
> >>>>+		;
> >>>>+	--hr_cmd->token_mask;
> >>>It doesn't look that you dynamically change max_cmds supported.
> >>>Why do you need to calculate token_mask dynamically?
> >>Hi, Leon
> >>
> >>     1. The four lines above are in the function named
> >>hns_roce_cmd_use_events.
> >>          and now this function is only called once in hns_roce_probe.
> >>     2. In hns_roce_cmd_use_events,
> >>         we use these 4 lines to achieve the value of hr_cmd->token_mask
> >>according to hr_cmd->max_cmds dynamically,
> >>         then we only define one marco for hr_cmd->max_cmds as below:
> >>
> >>	#define CMD_MAX_NUM		32
> >>
> >>        And it looks more flexible.
> >It is called over engineering.
> >I would recommend to you to remove it.
> >
> >We don't need over complicated code which is executed
> >once with need to maintain with zero benefit.
> >
> >The other places need such simplification too.
> Hi, Leon
>=20
>         We will modify this place as below:
>         In hns_roce_hw_v1.c(for hip06 soc) file:
>=20
>             void hns_roce_v1_profile(struct hns_roce_dev *hr_dev)
>             {
>                 <snip>
>                 caps->max_cmds =3D 32;
>                 <snip>
>             }
>=20
>         In hns_roce_cmd.c file:
>=20
>   	  int hns_roce_cmd_init(struct hns_roce_dev *hr_dev)
> 	  {
> 	     <snip>
> 	     hr_dev->cmd.max_cmds =3D hr_dev->caps->max_cmds;
>      		<snip>
>           }
>=20
>        Can you give more suggestions?

I would be happy to do it if I had enough time to review this code.

General suggestion will be to ask yourself, if value is going to be
changed during the runtime. In case the answer is no, there is no room
to additional logic which translate constant to different value which
will be other constant.

You should do it across all the patchset.

So, in this specific case, the proposed change is not enough, you are
not solving an issue, but hiding it.

Thanks

>=20
>=20
> Regards
> Wei Hu
> >>Regards
> >>Wei Hu
> >>
> >>
> >>
>=20
>=20

--5G06lTa6Jq83wMTw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXahoaAAoJEORje4g2clinjC4QAKHJWmEErI6m2yg92120ERRt
opmx4na0PRVJt53OLOYxl3HuS3d/krgmymrkfm1zU/wRCdrOQH2BYHbjyweAwLpb
xtnUwJUTFOuqZZIJ+7DMTjhFb633vpWYbhtq73MXTqDU1/lEwq4ikOBoqjfcfZwC
U9S0yMReDTPZ4Fj6Sp58zboU8jN71qVQEo5wADdKh5HU7KxzeWU5SqhXaKPSU7UY
w4n529JtQpoZrnjWIWjWdJrSVu6n+EM4VXs1fyBq8bTUevMISvAQ5MxZmBK5mMeC
4mV7RVIJPO7tyuM6c75BUNLTLAAm2bJn3sFk0LQImU1yxQB5ctf1vPEheVCptKQA
hKI1YanvlNfqvtz/xbt1IoHwsVMBfnpCnLJBu87z1amkolBTCs1WbZuPx6dZm5jd
ksLFsPGJ4VOd3K6uqAcBmCD1XtBrDFIy179SgtABg9RKhLqkz0w+ExOQxgcbVyj2
nxk/iG/Ep/zrhDNq8TX9kNXf2NEK0+n6ycK/dHxV8byrGW0cUfHXNyvlKCtxCU5N
t2kS/RnHqS4Yg9a8JpDXA/WFH9ZNVhM0xWkiuRu+kOl0Y+HW42zSHCIyeZGdK9iM
l9U1o6CVXmfr6WgpfM/FIu4FvaKk2dGb9y8r4I0nU0/F3B4jG71FzhAtui6v7j5f
1XtYWFv6x03CaJ1Nw50C
=apVt
-----END PGP SIGNATURE-----

--5G06lTa6Jq83wMTw--
