From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: SoCFPGA ethernet broken
Date: Thu, 3 Dec 2015 17:17:27 -0600
Message-ID: <5660CD87.5050603@opensource.altera.com>
References: <561FF9E2.30102@opensource.altera.com> <56200687.9040903@gmail.com> <562005AD.8020903@opensource.altera.com> <56200BD7.8020505@gmail.com> <20151203204811.GB14427@amd> <5660B2EC.1050705@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <david.daney@cavium.com>,
	<netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Daney <ddaney@caviumnetworks.com>,
	Pavel Machek <pavel@denx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5660B2EC.1050705@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/03/2015 03:23 PM, David Daney wrote:
> On 12/03/2015 12:48 PM, Pavel Machek wrote:
>> On Thu 2015-10-15 13:25:59, Florian Fainelli wrote:
>>> On 15/10/15 12:59, Dinh Nguyen wrote:
>>>> On 10/15/2015 03:03 PM, Florian Fainelli wrote:
>>>>> On 15/10/15 12:09, Dinh Nguyen wrote:
>>>>>> Hi,
>>>>>>
>>>>>> commit "8b63ec1837fa phylib: Make PHYs children of their MDIO bus,
>>>>>> not
>>>>>> the bus' parent." seems to have broken ethernet support for the
>>>>>> SoCFPGA
>>>>>> platform which is using the stmmac ethernet driver.
>>>>>
>>>>> It is not clear to me how this relates to what you are seeing yet.
>>>>>
>>>>>>
>>>>>> It appears that during DHCP, it cannot get an IP address. This only
>>>>>> happens if ethernet was not used by the bootloader to tftp an kernel
>>>>>> image. If I use the bootloader to tftp an image then ethernet is
>>>>>> working
>>>>>> fine. So I think the PHY is not getting enabled properly.
>>>>>>
>>>>>> If I revert this patch, then ethernet is back to working on the
>>>>>> platform.
>>>>>
>>>>> Is the Device Tree source for this platform available somewhere to
>>>>> look at?
>>>>>
>>>>
>>>> Yes, I'm using the DTS that is in the mainline:
>>>>
>>>> arch/arm/boot/dts/socfpga.dtsi
>>>> arch/arm/boot/dts/socfpga_cyclone5.dtsi
>>>> arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
>>>
>>> There are no PHY devices in any of these DTS files, instead there is the
>>> non-standard "phy-addr" property which is set to 0xffffffff supposedly
>>> to indicate that the MDIO bus should be scanned. This is likely part of
>>> your problem. The stmmac driver seems to be looking for "snps,phy-addr"
>>> and not "phy-addr", so I am not even clear how this is supposed to work,
>>> and the driver mentions this custom property is deprecated anyway.
>>>
>>> The core problem is in
>>> drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c::stmmac_mdio_register
>>> which manually detects the PHY, that is mostly fine, except that it does
>>> not really seem to work here for a reason that is still unclear to me.
>>>
>>> Your Ethernet PHYs need to be declared in Device Tree, see
>>> Documentation/devicetree/bindings/net/phy.txt
>>
>> While updating DTS might be good idea, I don't think you can simply
>> blame this on DTS. If it worked before the change, it is supposed to
>> work after the change, otherwise we call that change a "regression"
>> and revert the change.
> 
> FWIW: My initial patch to address the failure worked with the original DTB.
> 

Can I ask what patch are you referring to? I was sidetracked for a while
on this issue, but I still see it failing as of v4.4-rc3. I'll try to
get back to debugging this.

Dinh
