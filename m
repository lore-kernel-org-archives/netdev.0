From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: SoCFPGA ethernet broken
Date: Thu, 15 Oct 2015 15:49:28 -0500
Message-ID: <56201158.8040806@opensource.altera.com>
References: <561FF9E2.30102@opensource.altera.com> <56200687.9040903@gmail.com> <562005AD.8020903@opensource.altera.com> <56200BD7.8020505@gmail.com> <56200E15.9080603@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <david.daney@cavium.com>,
	<netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Daney <ddaney@caviumnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56200E15.9080603@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/15/2015 03:35 PM, David Daney wrote:
> On 10/15/2015 01:25 PM, Florian Fainelli wrote:
>> On 15/10/15 12:59, Dinh Nguyen wrote:
>>> On 10/15/2015 03:03 PM, Florian Fainelli wrote:
>>>> On 15/10/15 12:09, Dinh Nguyen wrote:
>>>>> Hi,
>>>>>
>>>>> commit "8b63ec1837fa phylib: Make PHYs children of their MDIO bus, not
>>>>> the bus' parent." seems to have broken ethernet support for the
>>>>> SoCFPGA
>>>>> platform which is using the stmmac ethernet driver.
>>>>
>>>> It is not clear to me how this relates to what you are seeing yet.
>>>>
>>>>>
>>>>> It appears that during DHCP, it cannot get an IP address. This only
>>>>> happens if ethernet was not used by the bootloader to tftp an kernel
>>>>> image. If I use the bootloader to tftp an image then ethernet is
>>>>> working
>>>>> fine. So I think the PHY is not getting enabled properly.
>>>>>
>>>>> If I revert this patch, then ethernet is back to working on the
>>>>> platform.
>>>>
>>>> Is the Device Tree source for this platform available somewhere to
>>>> look at?
>>>>
>>>
>>> Yes, I'm using the DTS that is in the mainline:
>>>
>>> arch/arm/boot/dts/socfpga.dtsi
>>> arch/arm/boot/dts/socfpga_cyclone5.dtsi
>>> arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
>>
>> There are no PHY devices in any of these DTS files, instead there is the
>> non-standard "phy-addr" property which is set to 0xffffffff supposedly
>> to indicate that the MDIO bus should be scanned. This is likely part of
>> your problem. The stmmac driver seems to be looking for "snps,phy-addr"
>> and not "phy-addr", so I am not even clear how this is supposed to work,
>> and the driver mentions this custom property is deprecated anyway.
>>
> 
> I think it is OK not to expose the PHYs in the device tree if they can
> be accurately probed without knowing information from the device tree.
> 
>> The core problem is in
>> drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c::stmmac_mdio_register
>> which manually detects the PHY, that is mostly fine, except that it does
>> not really seem to work here for a reason that is still unclear to me.
>>
> 
> I agree with this analysis.  I have also been looking at the code and
> cannot see anything that depends on what the parent device of the PHY
> is.  So it is a bit mystifying.
> 
> 
> I noticed in your original message you had in the boot log this:
> 
> .
> .
> .
> [    0.804992] libphy: stmmac: probed
> [    0.808410] eth0: PHY ID 00221611 at 4 IRQ POLL (stmmac-0:04) active
> .
> .
> .
> 
> Does this text change with and without the 8b63ec1837fa patch?

No, this text does not change with/without the 8b63ec1837fa patch.

Dinh
