From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: Re: [PATCH net-next v3 02/13] phy: add the mvebu cp110 comphy driver
Date: Wed, 30 Aug 2017 11:01:56 +0530
Message-ID: <04b4bb43-02f8-7b6b-f47f-f2d94d23d3f0@ti.com>
References: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
 <20170828145725.2539-3-antoine.tenart@free-electrons.com>
 <50072fdd-d370-8518-a9f4-73e121114e67@ti.com> <20170829112340.GB31552@kwain>
 <d1d5212d-aa39-0b49-afb8-cc45d57717c0@ti.com> <20170829131231.GD31552@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <andrew@lunn.ch>, <jason@lakedaemon.net>,
        <sebastian.hesselbarth@gmail.com>,
        <gregory.clement@free-electrons.com>,
        <thomas.petazzoni@free-electrons.com>, <nadavh@marvell.com>,
        <linux@armlinux.org.uk>, <linux-kernel@vger.kernel.org>,
        <mw@semihalf.com>, <stefanc@marvell.com>,
        <miquel.raynal@free-electrons.com>, <netdev@vger.kernel.org>
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:58116 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750890AbdH3FcW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 01:32:22 -0400
In-Reply-To: <20170829131231.GD31552@kwain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tuesday 29 August 2017 06:42 PM, Antoine Tenart wrote:
> Hi Kishon,
> 
> On Tue, Aug 29, 2017 at 05:55:06PM +0530, Kishon Vijay Abraham I wrote:
>> On Tuesday 29 August 2017 04:53 PM, Antoine Tenart wrote:
>>> On Tue, Aug 29, 2017 at 04:34:17PM +0530, Kishon Vijay Abraham I wrote:
>>>> On Monday 28 August 2017 08:27 PM, Antoine Tenart wrote:
>>>>> +static const struct mvebu_comhy_conf mvebu_comphy_cp110_modes[] = {
>>>>> +	/* lane 0 */
>>>>> +	MVEBU_COMPHY_CONF(0, 1, PHY_MODE_SGMII, 0x1),
>>>>> +	/* lane 1 */
>>>>> +	MVEBU_COMPHY_CONF(1, 2, PHY_MODE_SGMII, 0x1),
>>>>> +	/* lane 2 */
>>>>> +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_SGMII, 0x1),
>>>>> +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_10GKR, 0x1),
>>>>> +	/* lane 3 */
>>>>> +	MVEBU_COMPHY_CONF(3, 1, PHY_MODE_SGMII, 0x2),
>>>>> +	/* lane 4 */
>>>>> +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_SGMII, 0x2),
>>>>> +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_10GKR, 0x2),
>>>>> +	MVEBU_COMPHY_CONF(4, 1, PHY_MODE_SGMII, 0x1),
>>>>> +	/* lane 5 */
>>>>> +	MVEBU_COMPHY_CONF(5, 2, PHY_MODE_SGMII, 0x1),
>>>>> +};
>>>>
>>>> IMHO all the lane and mode configuration should come from dt. That would make
>>>> it more reusable when comphy is configured differently.
>>>
>>> These connexions between engines and the comphy lanes are inside the
>>> SoC. They won't change for a given SoC, and the actual configuration is
>>> at the board level to know what is connected to the output of a given
>>> lane, which is already described into the dt (the lane phandle).
>>>
>>> So I think we can keep this inside the driver, and we'll had other
>>> tables if the same comphy is ever used in another SoC.
>>>
>>> What do you think?
>>
>> I'd like to avoid adding tables for every SoC. These are configuration details
>> and can come from dt.
> 
> Actually this is per CP design, not SoC (this one is used in both 7k and
> 8k SoCs from Marvell, and probably others). I'm still not convinced this
> is a good idea to put this into the dt. First of all we would end up with
> something like (and this is only for a single lane, out of *6*):
> 
> cpm_comphy: phy@phy@120000 {
> 	compatible = "marvell,comphy-cp110";
> 	reg = <0x120000 0x6000>;
> 	marvell,system-controller = <&cpm_syscon0>;
> 	#address-cells = <1>;
> 	#size-cells = <0>;
> 
> 	cpm_comphy0: phy@0 {
> 		reg = <0>;
> 		#phy-cells = <1>;
> 
> 		mode@0 {
> 			phy-mode = PHY_MODE_SGMII;
> 			selector = <0x1>;
> 			pipe-selector = <0x0>;
> 			port = <0>;
> 		};
> 
> 		mode@1 {
> 			phy-mode = PHY_MODE_HS_SGMII;
> 			selector = <0x1>;
> 			pipe-selector = <0x0>;
> 			port = <0>;
> 		};
> 
> 		mode@2 {
> 			phy-mode = PHY_MODE_RXAUI;
> 			selector = <0x2>;
> 			pipe-selector = <0x0>;
> 			port = <0>;
> 		};
> 
> 		mode@3 {
> 			phy-mode = PHY_MODE_10GKR;
> 			selector = <0x2>;
> 			pipe-selector = <0x0>;
> 			port = <0>;
> 		};
> 
> 		mode@4 {
> 			phy-mode = PHY_MODE_SATA;
> 			selector = <0x4>;
> 			pipe-selector = <0x0>;
> 			port = <1>;
> 		};
> 
> 		mode@5 {
> 			phy-mode = PHY_MODE_USB;
> 			selector = <0x0>;
> 			pipe-selector = <0x1>;
> 			port = <2>;
> 		};
> 
> 		mode@6 {
> 			phy-mode = PHY_MODE_USB;
> 			selector = <0x0>;
> 			pipe-selector = <0x2>;
> 			port = <0>;
> 		};

I think we should just select the mode that a particular lane has been
configured here instead of populating all the modes. But I think that doesn't
make sense since the mode is set by the consumer and the initial mode is
INVALID. So ignore my comment on having it in dt.
> 
> 		... + PCIe, other ports ...
> 	};
> 
> 	cpm_comphy1: phy@1 {
> 		...
> 	};
> 
> 	...
> };
> 
> And this "configuration" makes us think the comphy driver would be
> somehow generic with only these parameters to update when using a
> different CP. In reality we do have one other comphy in another CP, and
> it requires more than just updating the above parameters: the init
> functions also are SoC specific. So the table used in the patch proposed
> only is a small part of this "configuration". In fact it's not a
> configuration at all, but only a mode-to-bit indirection, used in the
> comphy init functions.
> 
> What is proposed instead, is very close to what actually changes a lot,
> and what a designer can change: the CP internals are described in the
> driver as these won't change (and if they do in a future CP design, a
> lot more effort would be needed than just updating the table), and the
> actual lane connexions on the board are configured through the dt, which
> is board specific.
> 
> Finally we do not have (yet) any example of this IP being reused as-is.
> So we have no idea what other changes than the ones described above will
> be needed. But for sure not only the mode and lane configurations.

Thanks for the detailed explanation.

Thanks
Kishon
