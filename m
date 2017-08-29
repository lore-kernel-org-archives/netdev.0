From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: Re: [PATCH net-next v3 02/13] phy: add the mvebu cp110 comphy driver
Date: Tue, 29 Aug 2017 17:55:06 +0530
Message-ID: <d1d5212d-aa39-0b49-afb8-cc45d57717c0@ti.com>
References: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
 <20170828145725.2539-3-antoine.tenart@free-electrons.com>
 <50072fdd-d370-8518-a9f4-73e121114e67@ti.com> <20170829112340.GB31552@kwain>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170829112340.GB31552@kwain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tuesday 29 August 2017 04:53 PM, Antoine Tenart wrote:
> Hi Kishon,
> 
> On Tue, Aug 29, 2017 at 04:34:17PM +0530, Kishon Vijay Abraham I wrote:
>> On Monday 28 August 2017 08:27 PM, Antoine Tenart wrote:
>>>  
>>> +config PHY_MVEBU_CP110_COMPHY
>>> +	tristate "Marvell CP110 comphy driver"
>>> +	depends on ARCH_MVEBU && OF
>>
>> (ARCH_MVEBU || COMPILE_TEST) above..
> 
> Sure, I'll update.
> 
>>> +static const struct mvebu_comhy_conf mvebu_comphy_cp110_modes[] = {
>>> +	/* lane 0 */
>>> +	MVEBU_COMPHY_CONF(0, 1, PHY_MODE_SGMII, 0x1),
>>> +	/* lane 1 */
>>> +	MVEBU_COMPHY_CONF(1, 2, PHY_MODE_SGMII, 0x1),
>>> +	/* lane 2 */
>>> +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_SGMII, 0x1),
>>> +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_10GKR, 0x1),
>>> +	/* lane 3 */
>>> +	MVEBU_COMPHY_CONF(3, 1, PHY_MODE_SGMII, 0x2),
>>> +	/* lane 4 */
>>> +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_SGMII, 0x2),
>>> +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_10GKR, 0x2),
>>> +	MVEBU_COMPHY_CONF(4, 1, PHY_MODE_SGMII, 0x1),
>>> +	/* lane 5 */
>>> +	MVEBU_COMPHY_CONF(5, 2, PHY_MODE_SGMII, 0x1),
>>> +};
>>
>> IMHO all the lane and mode configuration should come from dt. That would make
>> it more reusable when comphy is configured differently.
> 
> These connexions between engines and the comphy lanes are inside the
> SoC. They won't change for a given SoC, and the actual configuration is
> at the board level to know what is connected to the output of a given
> lane, which is already described into the dt (the lane phandle).
> 
> So I think we can keep this inside the driver, and we'll had other
> tables if the same comphy is ever used in another SoC.
> 
> What do you think?

I'd like to avoid adding tables for every SoC. These are configuration details
and can come from dt.

Thanks
Kishon
