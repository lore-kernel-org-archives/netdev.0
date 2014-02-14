From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v5 09/10] Documentation: add Device tree bindings
 for Broadcom GENET
Date: Fri, 14 Feb 2014 09:36:26 -0800
Message-ID: <CAGVrzcYY+sf2JtscO+fDZ+Z9SoEbzVdMQYXtV+_0+e9pY0be9w@mail.gmail.com>
References: <1392336531-28875-1-git-send-email-f.fainelli@gmail.com>
 <1392336531-28875-10-git-send-email-f.fainelli@gmail.com> <20140214101942.GA9907@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"cernekee@gmail.com" <cernekee@gmail.com>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:62617 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbaBNRhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 12:37:07 -0500
In-Reply-To: <20140214101942.GA9907@e106331-lin.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-14 2:19 GMT-08:00 Mark Rutland <mark.rutland@arm.com>:
> On Fri, Feb 14, 2014 at 12:08:50AM +0000, Florian Fainelli wrote:
>> This patch adds the Device Tree bindings for the Broadcom GENET Gigabit
>> Ethernet controller. A bunch of examples are provided to illustrate the
>> versatile aspect of the hardare.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>> Changes in v5:
>> - respin due to the CONFIG_OF dependency fix
>>
>> Changes in v4:
>> - respin due to the Kconfig dependency
>>
>> Changes in v3
>> - improve compatible property description to specify all compatible strings
>>   supported
>> - move MDIO bus node to a separate section, to separate from the properties
>> - detail which exact phy-mode strings are supported and that this refers to
>>   the ePAPR 'phy-connection-type' modes
>> - fixed MDIO bus node compatible string to match what is really provided by
>>   the bootloader and use the same details as for the GENET compatible string
>> - add address-cells and size-cells required properties for the GENET device
>>   tree node
>> - add a better description for the 'fixed-link' property with reference to
>>   existing binding documentation
>> - add a reference to the Ethernet PHY device tree binding
>> - add a description for the interrupts properties
>> - add a documentation for the optional clocks properties
>> - removed unused and deprecated device_type properties
>>
>> Changes in v2:
>> - rebased against net-next/master
>>
>>  .../devicetree/bindings/net/broadcom-bcmgenet.txt  | 121 +++++++++++++++++++++
>>  1 file changed, 121 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
>> new file mode 100644
>> index 0000000..afd31f9
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
>> @@ -0,0 +1,121 @@
>> +* Broadcom BCM7xxx Ethernet Controller (GENET)
>> +
>> +Required properties:
>> +- compatible: should contain one of "brcm,genet-v1", "brcm,genet-v2",
>> +  "brcm,genet-v3", "brcm,genet-v4".
>> +- reg: address and length of the register set for the device
>> +- interrupts: must be two cells, the first cell is the general purpose
>> +  interrupt line, while the second cell is the interrupt for the ring
>> +  RX and TX queues operating in ring mode
>> +- phy-mode: String, operation mode of the PHY interface. Supported values are
>> +  "mii", "rgmii", "rgmii-txid", "rev-mii", "moca". Analogous to ePAPR
>> +  "phy-connection-type" values
>> +- address-cells: should be 1
>> +- size-cells: should be 1
>> +
>> +Optional properties:
>> +- clocks: When provided, must be two cells, first one is the main GENET clock
>> +  and the second cell is the Genet Wake-on-LAN clock.
>
> Clocks aren't just cells. They are referred to with phandle +
> clock-specificer pairs.
>
> This doesn't document the names that the driver requests the clocks by.
> Just listing the clocks isn't sufficient, as any dts will have to add a
> clock-names property to get those clocks probed.

I will follow up with a fix for this, thanks!
-- 
Florian
