From: Heiko Schocher <hs@denx.de>
Subject: Re: [PATCH v3 4/7] ARM: davinci: net: davinci_emac: add OF support
Date: Thu, 17 May 2012 08:32:27 +0200
Message-ID: <4FB49B7B.60506@denx.de>
References: <1330945804-3379-1-git-send-email-hs@denx.de>
 <1330945804-3379-5-git-send-email-hs@denx.de>
 <DF0F476B391FA8409C78302C7BA518B63EA14401@DBDE01.ent.ti.com>
Reply-To: hs@denx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: "davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Wolfgang Denk <wd@denx.de>, Anatoly Sivov <mm05@mail.ru>
To: "Nori, Sekhar" <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from b.relay.invitel.net ([62.77.203.4]:58516 "EHLO
	b.relay.invitel.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757932Ab2EQGcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 02:32:35 -0400
In-reply-to: <DF0F476B391FA8409C78302C7BA518B63EA14401@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Nori,

thanks for the review!

Nori, Sekhar wrote:
> Hi Heiko,
> 
> On Mon, Mar 05, 2012 at 16:40:01, Heiko Schocher wrote:
>> add of support for the davinci_emac driver.
>>
>> Signed-off-by: Heiko Schocher <hs@denx.de>
>> Cc: davinci-linux-open-source@linux.davincidsp.com
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: devicetree-discuss@lists.ozlabs.org
>> Cc: netdev@vger.kernel.org
>> Cc: Grant Likely <grant.likely@secretlab.ca>
>> Cc: Sekhar Nori <nsekhar@ti.com>
>> Cc: Wolfgang Denk <wd@denx.de>
>> Cc: Anatoly Sivov <mm05@mail.ru>
>>
>> ---
>> - changes for v2:
>>   - add comment from Anatoly Sivov
>>     - fix typo in davinci_emac.txt
>>   - add comment from Grant Likely:
>>     - add prefix "ti,davinci-" to davinci specific property names
>>     - remove version property
>>     - use compatible name "ti,davinci-dm6460-emac"
>>     - use devm_kzalloc()
>>     - use of_match_ptr()
>>     - document all new properties
>>     - remove of_address_to_resource() and do not overwrite
>>       resource table
>>     - whitespace fixes
>>     - remove hw_ram_addr as it is not used in current
>>       board code
>> - no changes for v3
>>
>>  .../bindings/arm/davinci/davinci_emac.txt          |   43 +++++++++
>>  drivers/net/ethernet/ti/davinci_emac.c             |   94 +++++++++++++++++++-
>>  2 files changed, 136 insertions(+), 1 deletions(-)
>>  create mode 100644 Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt
>>
>> diff --git a/Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt b/Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt
>> new file mode 100644
>> index 0000000..a7b0911
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/arm/davinci/davinci_emac.txt
> 
> Since DaVinci EMAC driver may be used on platforms other than DaVinci (c6x,
> OMAP), can we place the bindings documentation in bindings/net/?

Done.

>> @@ -0,0 +1,43 @@
>> +* Texas Instruments Davinci EMAC
>> +
>> +This file provides information, what the device node
>> +for the davinci_emac interface contain.
> 
> s/contain/contains

fixed.

>> +
>> +Required properties:
>> +- compatible: "ti,davinci-dm6460-emac";
> 
> There is no device called dm6460. If you intend to only support
> "version 2" of the EMAC IP at this time, you can use dm6467
> (http://www.ti.com/product/tms320dm6467)

renamed to "ti,davinci-dm6467-emac"

>> +- reg: Offset and length of the register set for the device
>> +- ti,davinci-ctrl-reg-offset: offset to control register
>> +- ti,davinci-ctrl-mod-reg-offset: offset to control module register
>> +- ti,davinci-ctrl-ram-offset: offset to control module ram
>> +- ti,davinci-ctrl-ram-size: size of control module ram
>> +- ti,davinci-rmii-en: use RMII
>> +- ti,davinci-no-bd-ram: has the emac controller BD RAM
>> +- phy-handle: Contains a phandle to an Ethernet PHY.
>> +              if not, davinci_emac driver defaults to 100/FULL
>> +- interrupts: interrupt mapping for the davinci emac interrupts sources:
>> +              4 sources: <Receive Threshold Interrupt
>> +			  Receive Interrupt
>> +			  Transmit Interrupt
>> +			  Miscellaneous Interrupt>
>> +- pinmux-handle: Contains a handle to configure the pinmux settings.

removed.

>> +
>> +Optional properties:
>> +- local-mac-address : 6 bytes, mac address
>> +
>> +Example (enbw_cmc board):
>> +	eth0: emac@1e20000 {
>> +		compatible = "ti,davinci-dm6460-emac";
>> +		reg = <0x220000 0x4000>;
>> +		ti,davinci-ctrl-reg-offset = <0x3000>;
>> +		ti,davinci-ctrl-mod-reg-offset = <0x2000>;
>> +		ti,davinci-ctrl-ram-offset = <0>;
>> +		ti,davinci-ctrl-ram-size = <0x2000>;
>> +		local-mac-address = [ 00 00 00 00 00 00 ];
>> +		interrupts = <33
>> +				34
>> +				35
>> +				36
>> +				>;
>> +		interrupt-parent = <&intc>;
>> +		pinmux-handle = <&emac_pins>;

removed.

>> +	};
>> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
>> index 4fa0bcb..56e1c35 100644
>> --- a/drivers/net/ethernet/ti/davinci_emac.c
>> +++ b/drivers/net/ethernet/ti/davinci_emac.c
>> @@ -58,6 +58,12 @@
>>  #include <linux/io.h>
>>  #include <linux/uaccess.h>
>>  #include <linux/davinci_emac.h>
>> +#include <linux/of.h>
>> +#include <linux/of_address.h>
>> +#include <linux/of_irq.h>
>> +#include <linux/of_net.h>
>> +
>> +#include <mach/mux.h>
>>  
>>  #include <asm/irq.h>
>>  #include <asm/page.h>
>> @@ -339,6 +345,9 @@ struct emac_priv {
>>  	u32 rx_addr_type;
>>  	atomic_t cur_tx;
>>  	const char *phy_id;
>> +#ifdef CONFIG_OF
>> +	struct device_node *phy_node;
>> +#endif
>>  	struct phy_device *phydev;
>>  	spinlock_t lock;
>>  	/*platform specific members*/
>> @@ -1760,6 +1769,82 @@ static const struct net_device_ops emac_netdev_ops = {
>>  #endif
>>  };
>>  
>> +#ifdef CONFIG_OF
>> +static struct emac_platform_data
>> +	*davinci_emac_of_get_pdata(struct platform_device *pdev,
>> +	struct emac_priv *priv)
>> +{
>> +	struct device_node *np;
>> +	struct device_node *pinmux_np;
>> +	struct emac_platform_data *pdata = NULL;
>> +	const u8 *mac_addr;
>> +	u32 data;
>> +	int ret;
>> +	int version;
>> +
>> +	np = pdev->dev.of_node;
>> +	if (!np)
>> +		goto nodata;
>> +	else
>> +		version = EMAC_VERSION_2;
> 
> You could set pdata->version directly here. 

done.

>> +
>> +	pdata = pdev->dev.platform_data;
>> +	if (!pdata) {
>> +		pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
>> +		if (!pdata)
>> +			goto nodata;
>> +	}
>> +	pdata->version = version;
>> +
>> +	mac_addr = of_get_mac_address(np);
>> +	if (mac_addr)
>> +		memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);
>> +
>> +	ret = of_property_read_u32(np, "ti,davinci-ctrl-reg-offset", &data);
>> +	if (!ret)
>> +		pdata->ctrl_reg_offset = data;
>> +
>> +	ret = of_property_read_u32(np, "ti,davinci-ctrl-mod-reg-offset",
>> +		&data);
>> +	if (!ret)
>> +		pdata->ctrl_mod_reg_offset = data;
>> +
>> +	ret = of_property_read_u32(np, "ti,davinci-ctrl-ram-offset", &data);
>> +	if (!ret)
>> +		pdata->ctrl_ram_offset = data;
>> +
>> +	ret = of_property_read_u32(np, "ti,davinci-ctrl-ram-size", &data);
>> +	if (!ret)
>> +		pdata->ctrl_ram_size = data;
>> +
>> +	ret = of_property_read_u32(np, "ti,davinci-rmii-en", &data);
>> +	if (!ret)
>> +		pdata->rmii_en = data;
>> +
>> +	ret = of_property_read_u32(np, "ti,davinci-no-bd-ram", &data);
>> +	if (!ret)
>> +		pdata->no_bd_ram = data;
>> +
>> +	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
>> +	if (!priv->phy_node)
>> +		pdata->phy_id = "";
>> +
>> +	pinmux_np = of_parse_phandle(np, "pinmux-handle", 0);
>> +	if (pinmux_np)
>> +		davinci_cfg_reg_of(pinmux_np);
> 
> This is a DaVinci specific pinmux function and this
> driver can be used in non-DaVinci platforms like C6x
> and OMAP. So, it will not be correct to call a DaVinci
> specific function here.

Ah, right!

> Can you drop the pinmux from this patch for now? On DaVinci,

Done ... Hmm.. so I think, I should drop this for all patches
from my patchset, right?

> for pinmux, we need to migrate to drivers/pinctrl/ as well.

Ah, I see ... take a look at it, maybe I find time to do here
something ... or do you know about work in progress here?

> Doing this will also make this patch independent of the rest
> of this series can even be merged separately. Can you please
> make these changes and resend just this patch?

Yep, I do some test with the changes you requested and resend
this patch ... do you prefer some tree, which I should use as
base?

>> +
>> +	pdev->dev.platform_data = pdata;
>> +nodata:
>> +	return  pdata;
>> +}
>> +#else
>> +static struct emac_platform_data
>> +	*davinci_emac_of_get_pdata(struct platform_device *pdev,
>> +	struct emac_priv *priv)
>> +{
>> +	return  pdev->dev.platform_data;
>> +}
>> +#endif
>>  /**
>>   * davinci_emac_probe: EMAC device probe
>>   * @pdev: The DaVinci EMAC device that we are removing
>> @@ -1803,7 +1888,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
>>  
>>  	spin_lock_init(&priv->lock);
>>  
>> -	pdata = pdev->dev.platform_data;
>> +	pdata = davinci_emac_of_get_pdata(pdev, priv);
>>  	if (!pdata) {
>>  		dev_err(&pdev->dev, "no platform data\n");
>>  		rc = -ENODEV;
>> @@ -2013,6 +2098,12 @@ static const struct dev_pm_ops davinci_emac_pm_ops = {
>>  	.resume		= davinci_emac_resume,
>>  };
>>  
>> +static const struct of_device_id davinci_emac_of_match[] = {
>> +	{.compatible = "ti,davinci-dm6460-emac", },
> 
> This needs to be ti,davinci-dm6467-emac as well.

Yep, fixed.

bye,
Heiko
-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
