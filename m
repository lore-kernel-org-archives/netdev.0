From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [patch v2 net-next 00/13] net: hns: add support of ACPI
Date: Mon, 30 May 2016 11:28:33 +0300
Message-ID: <1464596913.27624.53.camel@linux.intel.com>
References: <1464574222-69608-1-git-send-email-yankejian@huawei.com>
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
In-Reply-To: <1464574222-69608-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-05-30 at 10:10 +0800, Kejian Yan wrote:
> This series adds HNS support of acpi. The routine will call some ACPI
> helper functions, like acpi_dev_found() and acpi_evaluate_dsm(), whic=
h
> are not included in other cases. In order to make system compile
> successfully in other cases except ACPI, it needs to add relative stu=
b
> functions to linux/acpi.h. And we use device property functions
> instead
> of serial helper functions to suport both DT and ACPI cases. And then
> add the supports of ACPI for HNS.

Looks better. I have only kinda bikeshedding comments in mind, which I
didn't put here, though there is one you perhaps need to address.

Otherwise FWIW:
Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

>=20
> change log:
> =C2=A0v1 -> v2:
> =C2=A01. use acpi_dev_found() instead of acpi_match_device_ids() to c=
heck
> if
> it is a acpi node.
> =C2=A02. use is_of_node() instead of IS_ENABLED() to check if it is a=
 DT
> node.
> =C2=A03. split the patch("add support of acpi for hns-mdio") into two
> patches:
> =C2=A0=C2=A0=C2=A0=C2=A03.1 Move to use fwnode_handle
> =C2=A0=C2=A0=C2=A0=C2=A03.2 Add ACPI
> =C2=A04. add the patch which subject is dsaf misc operation method
> =C2=A05. fix the comments by Andy Shevchenko
>=20
> Kejian Yan (13):
> =C2=A0 ACPI: bus: add stub acpi_dev_found() to linux/acpi.h
> =C2=A0 ACPI: bus: add stub acpi_evaluate_dsm() to linux/acpi.h
> =C2=A0 net: hisilicon: cleanup to prepare for other cases
> =C2=A0 net: hisilicon: add support of acpi for hns-mdio
> =C2=A0 net: hns: use device_* APIs instead of of_* APIs
> =C2=A0 net: hns: use platform_get_irq instead of irq_of_parse_and_map
> =C2=A0 net: hns: enet specify a reference to dsaf by fwnode_handle
> =C2=A0 net: hns: add uniform interface for phy connection
> =C2=A0 net: hns: add dsaf misc operation method
> =C2=A0 net: hns: dsaf adds support of acpi
> =C2=A0 net: hns: register phy device in each mac initial sequence
> =C2=A0 net: hns: implement the miscellaneous operation by asl
> =C2=A0 net: hns: net: hns: enet adds support of acpi
>=20
> =C2=A0drivers/net/ethernet/hisilicon/hns/hnae.c=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A018 +-
> =C2=A0drivers/net/ethernet/hisilicon/hns/hnae.h=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A05 +-
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c=C2=A0=C2=A0|=C2=
=A0=C2=A0=C2=A06 +-
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c |=C2=A0=C2=A0=
=C2=A06 +-
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c=C2=A0=C2=A0| =
247
> +++++++++++++++-----
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h=C2=A0=C2=A0|=C2=
=A0=C2=A0=C2=A04 +-
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 105 ++++++=
---
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |=C2=A0=C2=A0=
33 ++-
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 250
> ++++++++++++++++++---
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h |=C2=A0=C2=A0=
=C2=A07 +-
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c=C2=A0=C2=A0|=C2=
=A0=C2=A015 +-
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c=C2=A0=C2=A0|=C2=
=A0=C2=A0=C2=A05 +-
> =C2=A0.../net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c=C2=A0=C2=A0=C2=A0=
=C2=A0|=C2=A0=C2=A010 +-
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_enet.c=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A090 +++++---
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_enet.h=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A02 +-
> =C2=A0drivers/net/ethernet/hisilicon/hns/hns_ethtool.c=C2=A0=C2=A0=C2=
=A0|=C2=A0=C2=A0=C2=A02 +-
> =C2=A0drivers/net/ethernet/hisilicon/hns_mdio.c=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 147 +++++++-----
> =C2=A0include/linux/acpi.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=
=A0=C2=A013 ++
> =C2=A018 files changed, 710 insertions(+), 255 deletions(-)
>=20

--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
