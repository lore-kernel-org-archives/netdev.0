From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH net-next 01/19] net: hns: bug fix of ge reset sequence
Date: Tue, 21 Jun 2016 13:35:06 +0300
Message-ID: <1466505306.30123.203.camel@linux.intel.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
	 <1466481399-70080-2-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: liguozhu@huawei.com, huangdaode@hisilicon.com, arnd@arndb.de,
	andrew@lunn.ch, geliangtang@163.com, ivecera@redhat.com,
	fengguang.wu@intel.com, charles.chenxin@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linuxarm@huawei.com
To: Yisen Zhuang <Yisen.Zhuang@huawei.com>, davem@davemloft.net,
	salil.mehta@huawei.com, yankejian@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19000 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756AbcFUKgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 06:36:02 -0400
In-Reply-To: <1466481399-70080-2-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-06-21 at 11:56 +0800, Yisen Zhuang wrote:
> From: Qianqian Xie <xieqianqian@huawei.com>
>=20
> The bit fileds of PPE reset register are different between HNS v1 and
> HNS v2, but the current procedure just only match HNS v1. Here is a
> patch to fix it.
>=20
> Signed-off-by: Kejian Yan <yankejian@huawei.com>
> Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
> ---
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 6 +++++-
> =C2=A01 file changed, 5 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
> b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
> index 96cb628..09e60d6 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
> @@ -271,7 +271,11 @@ static void hns_dsaf_ge_srst_by_port(struct
> dsaf_device *dsaf_dev, u32 port,
> =C2=A0		}
> =C2=A0	} else {
> =C2=A0		reg_val_1 =3D 0x15540 << dsaf_dev->reset_offset;
> -		reg_val_2 =3D 0x100 << dsaf_dev->reset_offset;
> +
> +		if (AE_IS_VER1(dsaf_dev->dsaf_ver))
> +			reg_val_2 =3D 0x100 << dsaf_dev->reset_offset;
> +		else
> +			reg_val_2 =3D 0x40 << dsaf_dev->reset_offset;

reg_val_1 =3D 0x15540;
reg_val_2 =3D=C2=A0AE_IS_VER1(dsaf_dev->dsaf_ver) ? 0x100 : 0x40;

reg_val_1 <<=3D=C2=A0dsaf_dev->reset_offset;
reg_val_2 <<=3D=C2=A0dsaf_dev-
>reset_offset;


> =C2=A0
> =C2=A0		if (!dereset) {
> =C2=A0			dsaf_write_sub(dsaf_dev,
> DSAF_SUB_SC_GE_RESET_REQ1_REG,

--=20

Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
