From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [patch net-next 01/11] net: hisilicon: add support of acpi for
 hns-mdio
Date: Fri, 13 May 2016 15:59:31 +0300
Message-ID: <1463144371.17131.336.camel@linux.intel.com>
References: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
	 <1463127557-90824-2-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arnd@arndb.de, andrew@lunn.ch, geliangtang@163.com,
	ivecera@redhat.com, fengguang.wu@intel.com,
	charles.chenxin@huawei.com, haifeng.wei@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxarm@huawei.com
To: Yisen Zhuang <Yisen.Zhuang@huawei.com>, davem@davemloft.net,
	rjw@rjwysocki.net, lenb@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463127557-90824-2-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-05-13 at 16:19 +0800, Yisen Zhuang wrote:
> From: Kejian Yan <yankejian@huawei.com>
>=20
> hns-mdio needs to register itself to mii-bus. The info of the device
> can
> be read by both OF and ACPI.
> HNS tries to call Linux PHY driver to help access PHY-devices, the HN=
S
> hardware topology is as below. The MDIO controller may control severa=
l
> PHY-devices, and each PHY-device connects to a MAC device. The MDIO
> will
> be registered to mdiobus, then PHY-devices will register when each ma=
c
> find PHY device.
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0cp=
u
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0|
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0|
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0---------------------------------------=
----
> =C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|
> =C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|
> =C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0dsaf=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|
> =C2=A0=C2=A0=C2=A0MDIO=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0MDIO
> =C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0--------=
-------------------=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0|
> =C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|
> =C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|
> =C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=C2=A0MAC=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0MAC=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0MA=
C=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0MAC=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0|
> =C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0---- |-------- |-------- |=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0| --------
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0||=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0||=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0||=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0||
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0PHY=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0PHY=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0PHY=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0PHY
>=20
> And the driver can handle reset sequence by _DSD method in DSDT in
> ACPI case.
>=20
> Signed-off-by: Kejian Yan <yankejian@huawei.com>
> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
> ---
> =C2=A0drivers/net/ethernet/hisilicon/hns_mdio.c | 145 +++++++++++++++=
+++---
> ---------
> =C2=A01 file changed, 90 insertions(+), 55 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/hisilicon/hns_mdio.c
> b/drivers/net/ethernet/hisilicon/hns_mdio.c
> index 765ddb3..4b779df 100644
> --- a/drivers/net/ethernet/hisilicon/hns_mdio.c
> +++ b/drivers/net/ethernet/hisilicon/hns_mdio.c
> @@ -7,6 +7,7 @@
> =C2=A0 * (at your option) any later version.
> =C2=A0 */
> =C2=A0
> +#include <linux/acpi.h>
> =C2=A0#include <linux/errno.h>
> =C2=A0#include <linux/etherdevice.h>
> =C2=A0#include <linux/init.h>
> @@ -354,64 +355,72 @@ static int hns_mdio_reset(struct mii_bus *bus)
> =C2=A0	struct hns_mdio_device *mdio_dev =3D (struct hns_mdio_device
> *)bus->priv;
> =C2=A0	int ret;
> =C2=A0
> -	if (!mdio_dev->subctrl_vbase) {
> -		dev_err(&bus->dev, "mdio sys ctl reg has not
> maped\n");
> -		return -ENODEV;
> -	}
> -
> -	/*1. reset req, and read reset st check*/
> -	ret =3D mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_RESET_REQ, 0x1,
> -				=C2=A0=C2=A0=C2=A0=C2=A0MDIO_SC_RESET_ST, 0x1,
> -				=C2=A0=C2=A0=C2=A0=C2=A0MDIO_CHECK_SET_ST);
> -	if (ret) {
> -		dev_err(&bus->dev, "MDIO reset fail\n");
> -		return ret;
> -	}
> +	if (IS_ENABLED(CONFIG_OF) && bus->parent->of_node) {

Can you keep indentation the same?

Also I suggest to use struct fwnode_handle, and this will be something
like

if (is_of_node(...))

> +		if (!mdio_dev->subctrl_vbase) {
> +			dev_err(&bus->dev, "mdio sys ctl reg has not
> maped\n");
> +			return -ENODEV;
> +		}
> =C2=A0
> -	/*2. dis clk, and read clk st check*/
> -	ret =3D mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_CLK_DIS,
> -				=C2=A0=C2=A0=C2=A0=C2=A00x1, MDIO_SC_CLK_ST, 0x1,
> -				=C2=A0=C2=A0=C2=A0=C2=A0MDIO_CHECK_CLR_ST);
> -	if (ret) {
> -		dev_err(&bus->dev, "MDIO dis clk fail\n");
> -		return ret;
> -	}
> +		/*1. reset req, and read reset st check*/
> +		ret =3D mdio_sc_cfg_reg_write(mdio_dev,
> MDIO_SC_RESET_REQ, 0x1,
> +					=C2=A0=C2=A0=C2=A0=C2=A0MDIO_SC_RESET_ST, 0x1,
> +					=C2=A0=C2=A0=C2=A0=C2=A0MDIO_CHECK_SET_ST);
> +		if (ret) {
> +			dev_err(&bus->dev, "MDIO reset fail\n");
> +			return ret;
> +		}
> =C2=A0
> -	/*3. reset dreq, and read reset st check*/
> -	ret =3D mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_RESET_DREQ,
> 0x1,
> -				=C2=A0=C2=A0=C2=A0=C2=A0MDIO_SC_RESET_ST, 0x1,
> -				=C2=A0=C2=A0=C2=A0=C2=A0MDIO_CHECK_CLR_ST);
> -	if (ret) {
> -		dev_err(&bus->dev, "MDIO dis clk fail\n");
> -		return ret;
> -	}
> +		/*2. dis clk, and read clk st check*/
> +		ret =3D mdio_sc_cfg_reg_write(mdio_dev,
> MDIO_SC_CLK_DIS,
> +					=C2=A0=C2=A0=C2=A0=C2=A00x1, MDIO_SC_CLK_ST, 0x1,
> +					=C2=A0=C2=A0=C2=A0=C2=A0MDIO_CHECK_CLR_ST);
> +		if (ret) {
> +			dev_err(&bus->dev, "MDIO dis clk fail\n");
> +			return ret;
> +		}
> =C2=A0
> -	/*4. en clk, and read clk st check*/
> -	ret =3D mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_CLK_EN,
> -				=C2=A0=C2=A0=C2=A0=C2=A00x1, MDIO_SC_CLK_ST, 0x1,
> -				=C2=A0=C2=A0=C2=A0=C2=A0MDIO_CHECK_SET_ST);
> -	if (ret)
> -		dev_err(&bus->dev, "MDIO en clk fail\n");
> +		/*3. reset dreq, and read reset st check*/
> +		ret =3D mdio_sc_cfg_reg_write(mdio_dev,
> MDIO_SC_RESET_DREQ, 0x1,
> +					=C2=A0=C2=A0=C2=A0=C2=A0MDIO_SC_RESET_ST, 0x1,
> +					=C2=A0=C2=A0=C2=A0=C2=A0MDIO_CHECK_CLR_ST);
> +		if (ret) {
> +			dev_err(&bus->dev, "MDIO dis clk fail\n");
> +			return ret;
> +		}
> =C2=A0
> +		/*4. en clk, and read clk st check*/
> +		ret =3D mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_CLK_EN,
> +					=C2=A0=C2=A0=C2=A0=C2=A00x1, MDIO_SC_CLK_ST, 0x1,
> +					=C2=A0=C2=A0=C2=A0=C2=A0MDIO_CHECK_SET_ST);
> +		if (ret)
> +			dev_err(&bus->dev, "MDIO en clk fail\n");
> +	} else if (ACPI_COMPANION(bus->parent)) {
> +		acpi_status s;
> +
> +		s =3D acpi_evaluate_object(ACPI_HANDLE(bus->parent),
> +					=C2=A0"_RST", NULL, NULL);
> +		if (ACPI_FAILURE(s)) {
> +			dev_err(&bus->dev, "Reset failed,
> return:%#x\n", s);
> +			ret =3D -EBUSY;
> +		} else {
> +			ret =3D 0;
> +		}
> +	} else {
> +		dev_err(&bus->dev, "cannot get cfd data from of or
> acpi\n");

cannot -> Can not

WTF cfd?

of or acpi -> DT or ACPI

> +		ret =3D -ENXIO;
> +	}
> =C2=A0	return ret;
> =C2=A0}
> =C2=A0
> =C2=A0/**
> =C2=A0 * hns_mdio_bus_name - get mdio bus name
> =C2=A0 * @name: mdio bus name
> - * @np: mdio device node pointer
> + * @addr: mdio physical address
> =C2=A0 */
> -static void hns_mdio_bus_name(char *name, struct device_node *np)
> +static void hns_mdio_bus_name(char *name, phys_addr_t addr)
> =C2=A0{
> -	const u32 *addr;
> -	u64 taddr =3D OF_BAD_ADDR;
> -
> -	addr =3D of_get_address(np, 0, NULL, NULL);
> -	if (addr)
> -		taddr =3D of_translate_address(np, addr);
> -
> -	snprintf(name, MII_BUS_ID_SIZE, "%s@%llx", np->name,
> -		=C2=A0(unsigned long long)taddr);
> +	snprintf(name, MII_BUS_ID_SIZE,
> +		=C2=A0"hns-mdio@%llx", (unsigned long long)addr);
> =C2=A0}
> =C2=A0
> =C2=A0/**
> @@ -422,7 +431,6 @@ static void hns_mdio_bus_name(char *name, struct
> device_node *np)
> =C2=A0 */
> =C2=A0static int hns_mdio_probe(struct platform_device *pdev)
> =C2=A0{
> -	struct device_node *np;
> =C2=A0	struct hns_mdio_device *mdio_dev;
> =C2=A0	struct mii_bus *new_bus;
> =C2=A0	struct resource *res;
> @@ -432,7 +440,7 @@ static int hns_mdio_probe(struct platform_device
> *pdev)
> =C2=A0		dev_err(NULL, "pdev is NULL!\r\n");
> =C2=A0		return -ENODEV;
> =C2=A0	}
> -	np =3D pdev->dev.of_node;
> +
> =C2=A0	mdio_dev =3D devm_kzalloc(&pdev->dev, sizeof(*mdio_dev),
> GFP_KERNEL);
> =C2=A0	if (!mdio_dev)
> =C2=A0		return -ENOMEM;
> @@ -448,7 +456,6 @@ static int hns_mdio_probe(struct platform_device
> *pdev)
> =C2=A0	new_bus->write =3D hns_mdio_write;
> =C2=A0	new_bus->reset =3D hns_mdio_reset;
> =C2=A0	new_bus->priv =3D mdio_dev;
> -	hns_mdio_bus_name(new_bus->id, np);
> =C2=A0
> =C2=A0	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> =C2=A0	mdio_dev->vbase =3D devm_ioremap_resource(&pdev->dev, res);
> @@ -457,16 +464,37 @@ static int hns_mdio_probe(struct platform_devic=
e
> *pdev)
> =C2=A0		return ret;
> =C2=A0	}
> =C2=A0
> -	mdio_dev->subctrl_vbase =3D
> -		syscon_node_to_regmap(of_parse_phandle(np, "subctrl-
> vbase", 0));
> -	if (IS_ERR(mdio_dev->subctrl_vbase)) {
> -		dev_warn(&pdev->dev, "no syscon hisilicon,peri-c-
> subctrl\n");
> -		mdio_dev->subctrl_vbase =3D NULL;
> +	hns_mdio_bus_name(new_bus->id, res->start);
> +	if (IS_ENABLED(CONFIG_OF) && pdev->dev.of_node) {

is_of_node()

> +		mdio_dev->subctrl_vbase =3D syscon_node_to_regmap(
> +			of_parse_phandle(pdev->dev.of_node,
> +					=C2=A0"subctrl-vbase", 0));
> +		if (IS_ERR(mdio_dev->subctrl_vbase)) {
> +			dev_warn(&pdev->dev, "no syscon
> hisilicon,peri-c-subctrl\n");
> +			mdio_dev->subctrl_vbase =3D NULL;
> +		}
> =C2=A0	}
> =C2=A0	new_bus->parent =3D &pdev->dev;
> =C2=A0	platform_set_drvdata(pdev, new_bus);
> =C2=A0
> -	ret =3D of_mdiobus_register(new_bus, np);
> +	if (IS_ENABLED(CONFIG_OF) && pdev->dev.of_node) {

Ditto

> +		ret =3D of_mdiobus_register(new_bus, pdev-
> >dev.of_node);
> +	} else if (ACPI_COMPANION(&pdev->dev)) {

is_acpi_node()

> +		/* Clear all the IRQ properties */
> +		memset(new_bus->irq, PHY_POLL, 4 * PHY_MAX_ADDR);
> +
> +		/* Mask out all PHYs from auto probing. */
> +		new_bus->phy_mask =3D ~0;
> +
> +		/* Register the MDIO bus */
> +		ret =3D mdiobus_register(new_bus);
> +		if (ret)
> +			return ret;
> +	} else {
> +		dev_err(&pdev->dev, "cannot get cfd data from of or
> acpi\n");

Same as for previous message.

> +		return -ENXIO;
> +	}
> +
> =C2=A0	if (ret) {
> =C2=A0		dev_err(&pdev->dev, "Cannot register as MDIO
> bus!\n");
> =C2=A0		platform_set_drvdata(pdev, NULL);
> @@ -499,12 +527,19 @@ static const struct of_device_id
> hns_mdio_match[] =3D {
> =C2=A0	{}
> =C2=A0};
> =C2=A0
> +static const struct acpi_device_id hns_mdio_acpi_match[] =3D {
> +	{ "HISI0141", 0 },
> +	{ },
> +};
> +MODULE_DEVICE_TABLE(acpi, hns_mdio_acpi_match);
> +
> =C2=A0static struct platform_driver hns_mdio_driver =3D {
> =C2=A0	.probe =3D hns_mdio_probe,
> =C2=A0	.remove =3D hns_mdio_remove,
> =C2=A0	.driver =3D {
> =C2=A0		=C2=A0=C2=A0=C2=A0.name =3D MDIO_DRV_NAME,
> =C2=A0		=C2=A0=C2=A0=C2=A0.of_match_table =3D hns_mdio_match,
> +		=C2=A0=C2=A0=C2=A0.acpi_match_table =3D ACPI_PTR(hns_mdio_acpi_mat=
ch),
> =C2=A0		=C2=A0=C2=A0=C2=A0},
> =C2=A0};
> =C2=A0


So, I suggest to split this to two logical changes:

1. Move to use fwnode_handle
2. Add ACPI bits

--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
