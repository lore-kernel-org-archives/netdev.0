From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [patch v2 net-next 12/13] net: hns: implement the miscellaneous
 operation by asl
Date: Mon, 30 May 2016 11:25:56 +0300
Message-ID: <1464596756.27624.51.camel@linux.intel.com>
References: <1464574222-69608-1-git-send-email-yankejian@huawei.com>
	 <1464574222-69608-13-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fengguang.wu@intel.com, andrew@lunn.ch, ivecera@redhat.com,
	f.fainelli@gmail.com, haifeng.wei@huawei.com,
	charles.chenxin@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	linuxarm@huawei.com
To: Kejian Yan <yankejian@huawei.com>, rjw@rjwysocki.net,
	lenb@kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464574222-69608-13-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-05-30 at 10:10 +0800, Kejian Yan wrote:
> The miscellaneous operation is implemented in BIOS, the kernel can
> call
> _DSM method help to call the implementation in ACPI case. Here is a
> patch
> to do that.
>=20


> +static phy_interface_t hns_mac_get_phy_if_acpi(struct hns_mac_cb
> *mac_cb)
> +{
> +	phy_interface_t phy_if =3D PHY_INTERFACE_MODE_NA;
> +	union acpi_object *obj;
> +	union acpi_object obj_args, argv4;
> +
> +	obj_args.integer.type =3D ACPI_TYPE_INTEGER;
> +	obj_args.integer.value =3D mac_cb->mac_id;
> +
> +	argv4.type =3D ACPI_TYPE_PACKAGE,
> +	argv4.package.count =3D 1,
> +	argv4.package.elements =3D &obj_args,
> +
> +	obj =3D acpi_evaluate_dsm(ACPI_HANDLE(mac_cb->dev),
> +				hns_dsaf_acpi_dsm_uuid, 0,
> +				HNS_OP_GET_PORT_TYPE_FUNC, &argv4);
> +
> +	if (!obj || obj->type !=3D ACPI_TYPE_INTEGER)

Seems you have potential memory leak here

if (!obj)
=C2=A0return phy_if;

if (obj->...)
=C2=A0goto exit_free;


> +		return phy_if;
> +
> +	phy_if =3D obj->integer.value ?
> +		PHY_INTERFACE_MODE_XGMII : PHY_INTERFACE_MODE_SGMII;
> +
> +	dev_dbg(mac_cb->dev, "mac_id=3D%d, phy_if=3D%d\n", mac_cb-
> >mac_id, phy_if);
> +

+ exit_free:

> +	ACPI_FREE(obj);
> +
> +	return phy_if;
> +}
>=20

--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
