From: Maxime Coquelin <maxime.coquelin@st.com>
Subject: Re: [PATCH v2 2/7] phy: miphy365x: Pass sysconfig register offsets
 via syscfg dt property.
Date: Fri, 30 Jan 2015 11:48:46 +0100
Message-ID: <54CB618E.60808@st.com>
References: <1420643052-4506-1-git-send-email-peter.griffin@linaro.org> <1420643052-4506-3-git-send-email-peter.griffin@linaro.org> <54CB5E7E.8050507@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <lee.jones@linaro.org>, <devicetree@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Kishon Vijay Abraham I <kishon@ti.com>,
	Peter Griffin <peter.griffin@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <srinivas.kandagatla@gmail.com>,
	<patrice.chotard@st.com>, <peppe.cavallaro@st.com>, <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54CB5E7E.8050507@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kishon,

On 01/30/2015 11:35 AM, Kishon Vijay Abraham I wrote:
> Hi,
>
> On Wednesday 07 January 2015 08:34 PM, Peter Griffin wrote:
>> Based on Arnds review comments here https://lkml.org/lkml/2014/11/13/161,
>> update the miphy365 phy driver to access sysconfig register offsets via
>> syscfg dt property.
>>
>> This is because the reg property should not be mixing address spaces
>> like it does currently for miphy365. This change then also aligns us
>> to how other platforms such as keystone and bcm7445 pass there syscon
>> offsets via DT.
>>
>> This patch breaks DT compatibility, but this platform is considered WIP,
>> and is only used by a few developers who are upstreaming support for it.
>> This change has been done as a single atomic commit to ensure it is
>> bisectable.
> I'm dropping this from my tree since I didn't get Ack from
> "arch/arm/boot/dts/stih416.dtsi" Maintainer.
Sorry, on cover letter, I replied the series looked good to me.
So you can add:

Acked-by: Maxime Coquelin <maxime.coquelin@st.com>

And even:

Tested-by: Maxime Coquelin <maxime.coquelin@st.com>

Kind regards,
Maxime

>
> Thanks
> Kishon
>> Signed-off-by: Peter Griffin <peter.griffin@linaro.org>
>> Reviewed-by: Arnd Bergmann <arnd@arndb.de>
>> ---
>>   .../devicetree/bindings/phy/phy-miphy365x.txt      | 15 +++++------
>>   arch/arm/boot/dts/stih416.dtsi                     | 10 ++++----
>>   drivers/phy/phy-miphy365x.c                        | 29 ++++++++--------------
>>   3 files changed, 23 insertions(+), 31 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/phy/phy-miphy365x.txt b/Documentation/devicetree/bindings/phy/phy-miphy365x.txt
>> index 42c8808..9802d5d 100644
>> --- a/Documentation/devicetree/bindings/phy/phy-miphy365x.txt
>> +++ b/Documentation/devicetree/bindings/phy/phy-miphy365x.txt
>> @@ -6,8 +6,10 @@ for SATA and PCIe.
>>   
>>   Required properties (controller (parent) node):
>>   - compatible    : Should be "st,miphy365x-phy"
>> -- st,syscfg     : Should be a phandle of the system configuration register group
>> -		  which contain the SATA, PCIe mode setting bits
>> +- st,syscfg     : Phandle / integer array property. Phandle of sysconfig group
>> +		  containing the miphy registers and integer array should contain
>> +		  an entry for each port sub-node, specifying the control
>> +		  register offset inside the sysconfig group.
>>   
>>   Required nodes	:  A sub-node is required for each channel the controller
>>   		   provides. Address range information including the usual
>> @@ -26,7 +28,6 @@ Required properties (port (child) node):
>>   		  registers filled in "reg":
>>   			- sata:   For SATA devices
>>   			- pcie:   For PCIe devices
>> -			- syscfg: To specify the syscfg based config register
>>   
>>   Optional properties (port (child) node):
>>   - st,sata-gen	     :	Generation of locally attached SATA IP. Expected values
>> @@ -39,20 +40,20 @@ Example:
>>   
>>   	miphy365x_phy: miphy365x@fe382000 {
>>   		compatible      = "st,miphy365x-phy";
>> -		st,syscfg  	= <&syscfg_rear>;
>> +		st,syscfg  	= <&syscfg_rear 0x824 0x828>;
>>   		#address-cells	= <1>;
>>   		#size-cells	= <1>;
>>   		ranges;
>>   
>>   		phy_port0: port@fe382000 {
>> -			reg = <0xfe382000 0x100>, <0xfe394000 0x100>, <0x824 0x4>;
>> -			reg-names = "sata", "pcie", "syscfg";
>> +			reg = <0xfe382000 0x100>, <0xfe394000 0x100>;
>> +			reg-names = "sata", "pcie";
>>   			#phy-cells = <1>;
>>   			st,sata-gen = <3>;
>>   		};
>>   
>>   		phy_port1: port@fe38a000 {
>> -			reg = <0xfe38a000 0x100>, <0xfe804000 0x100>, <0x828 0x4>;;
>> +			reg = <0xfe38a000 0x100>, <0xfe804000 0x100>;;
>>   			reg-names = "sata", "pcie", "syscfg";
>>   			#phy-cells = <1>;
>>   			st,pcie-tx-pol-inv;
>> diff --git a/arch/arm/boot/dts/stih416.dtsi b/arch/arm/boot/dts/stih416.dtsi
>> index fad9073..85afe01 100644
>> --- a/arch/arm/boot/dts/stih416.dtsi
>> +++ b/arch/arm/boot/dts/stih416.dtsi
>> @@ -283,21 +283,21 @@
>>   
>>   		miphy365x_phy: phy@fe382000 {
>>   			compatible      = "st,miphy365x-phy";
>> -			st,syscfg  	= <&syscfg_rear>;
>> +			st,syscfg	= <&syscfg_rear 0x824 0x828>;
>>   			#address-cells	= <1>;
>>   			#size-cells	= <1>;
>>   			ranges;
>>   
>>   			phy_port0: port@fe382000 {
>>   				#phy-cells = <1>;
>> -				reg = <0xfe382000 0x100>, <0xfe394000 0x100>, <0x824 0x4>;
>> -				reg-names = "sata", "pcie", "syscfg";
>> +				reg = <0xfe382000 0x100>, <0xfe394000 0x100>;
>> +				reg-names = "sata", "pcie";
>>   			};
>>   
>>   			phy_port1: port@fe38a000 {
>>   				#phy-cells = <1>;
>> -				reg = <0xfe38a000 0x100>, <0xfe804000 0x100>, <0x828 0x4>;
>> -				reg-names = "sata", "pcie", "syscfg";
>> +				reg = <0xfe38a000 0x100>, <0xfe804000 0x100>;
>> +				reg-names = "sata", "pcie";
>>   			};
>>   		};
>>   
>> diff --git a/drivers/phy/phy-miphy365x.c b/drivers/phy/phy-miphy365x.c
>> index 6ab43a8..6c80154 100644
>> --- a/drivers/phy/phy-miphy365x.c
>> +++ b/drivers/phy/phy-miphy365x.c
>> @@ -141,7 +141,7 @@ struct miphy365x_phy {
>>   	bool pcie_tx_pol_inv;
>>   	bool sata_tx_pol_inv;
>>   	u32 sata_gen;
>> -	u64 ctrlreg;
>> +	u32 ctrlreg;
>>   	u8 type;
>>   };
>>   
>> @@ -179,7 +179,7 @@ static int miphy365x_set_path(struct miphy365x_phy *miphy_phy,
>>   	bool sata = (miphy_phy->type == MIPHY_TYPE_SATA);
>>   
>>   	return regmap_update_bits(miphy_dev->regmap,
>> -				  (unsigned int)miphy_phy->ctrlreg,
>> +				  miphy_phy->ctrlreg,
>>   				  SYSCFG_SELECT_SATA_MASK,
>>   				  sata << SYSCFG_SELECT_SATA_POS);
>>   }
>> @@ -445,7 +445,6 @@ int miphy365x_get_addr(struct device *dev, struct miphy365x_phy *miphy_phy,
>>   {
>>   	struct device_node *phynode = miphy_phy->phy->dev.of_node;
>>   	const char *name;
>> -	const __be32 *taddr;
>>   	int type = miphy_phy->type;
>>   	int ret;
>>   
>> @@ -455,22 +454,6 @@ int miphy365x_get_addr(struct device *dev, struct miphy365x_phy *miphy_phy,
>>   		return ret;
>>   	}
>>   
>> -	if (!strncmp(name, "syscfg", 6)) {
>> -		taddr = of_get_address(phynode, index, NULL, NULL);
>> -		if (!taddr) {
>> -			dev_err(dev, "failed to fetch syscfg address\n");
>> -			return -EINVAL;
>> -		}
>> -
>> -		miphy_phy->ctrlreg = of_translate_address(phynode, taddr);
>> -		if (miphy_phy->ctrlreg == OF_BAD_ADDR) {
>> -			dev_err(dev, "failed to translate syscfg address\n");
>> -			return -EINVAL;
>> -		}
>> -
>> -		return 0;
>> -	}
>> -
>>   	if (!((!strncmp(name, "sata", 4) && type == MIPHY_TYPE_SATA) ||
>>   	      (!strncmp(name, "pcie", 4) && type == MIPHY_TYPE_PCIE)))
>>   		return 0;
>> @@ -606,7 +589,15 @@ static int miphy365x_probe(struct platform_device *pdev)
>>   			return ret;
>>   
>>   		phy_set_drvdata(phy, miphy_dev->phys[port]);
>> +
>>   		port++;
>> +		/* sysconfig offsets are indexed from 1 */
>> +		ret = of_property_read_u32_index(np, "st,syscfg", port,
>> +					&miphy_phy->ctrlreg);
>> +		if (ret) {
>> +			dev_err(&pdev->dev, "No sysconfig offset found\n");
>> +			return ret;
>> +		}
>>   	}
>>   
>>   	provider = devm_of_phy_provider_register(&pdev->dev, miphy365x_xlate);
>>
