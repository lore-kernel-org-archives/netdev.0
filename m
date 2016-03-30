From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH net-next] net: hns: add support of pause frame ctrl for
 HNS V2
Date: Wed, 30 Mar 2016 13:51:13 +0300
Message-ID: <1459335073.5907.34.camel@linux.intel.com>
References: <1459235041-91766-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: charles.chenxin@huawei.com, haifeng.wei@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linuxarm@huawei.com
To: Yisen Zhuang <Yisen.Zhuang@huawei.com>, davem@davemloft.net,
	salil.mehta@huawei.com, liguozhu@huawei.com,
	huangdaode@hisilicon.com, arnd@arndb.de, andrew@lunn.ch,
	geliangtang@163.com, ivecera@redhat.com, lisheng011@huawei.com,
	fengguang.wu@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459235041-91766-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-03-29 at 15:04 +0800, Yisen Zhuang wrote:
> From: Lisheng <lisheng011@huawei.com>
>=20
> The patch adds support of pause ctrl for HNS V2, and this feature is
> lost
> by HNS V1:
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01) service ports can disabl=
e rx pause frame,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A02) debug ports can open tx/=
rx pause frame.
>=20
> And this patch updates the REGs about the pause ctrl when updated
> status function called by upper layer routine.

> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
>=20

> +void hns_dsaf_get_rx_mac_pause_en(struct dsaf_device *dsaf_dev, int
> mac_id,
> +				=C2=A0=C2=A0u32 *en)
> +{
> +	if (AE_IS_VER1(dsaf_dev->dsaf_ver))
> +		*en =3D 1;
> =C2=A0	else
> =C2=A0		dsaf_write_dev(dsaf_dev, DSAF_PFC_EN_0_REG + mac_id
> * 4, 0xff);
> +		*en =3D dsaf_get_dev_bit(dsaf_dev,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0DSAF_PAUSE_CFG_REG + m=
ac_id *
> 4,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0DSAF_MAC_PAUSE_RX_EN_B=
);

And what the point of if branch then? I think it's an obvious misfix,
you must replace else to } else { and add }.

How did you test this part?

> =C2=A0}


--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
