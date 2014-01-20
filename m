From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] DT: net: document Ethernet bindings in one place
Date: Tue, 21 Jan 2014 00:45:27 +0300
Message-ID: <52DD98F7.4090202@cogentembedded.com>
References: <201401180405.07859.sergei.shtylyov@cogentembedded.com> <CAL_Jsq+oa9P=rh+p-dMZyGP8TcmpX7bTnMU0ynLvFxjxFDYbRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Rob Landley <rob@landley.net>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:46603 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbaATUpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 15:45:31 -0500
Received: by mail-la0-f46.google.com with SMTP id b8so5906598lan.19
        for <netdev@vger.kernel.org>; Mon, 20 Jan 2014 12:45:29 -0800 (PST)
In-Reply-To: <CAL_Jsq+oa9P=rh+p-dMZyGP8TcmpX7bTnMU0ynLvFxjxFDYbRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2014 05:06 PM, Rob Herring wrote:

>> This patch is an attempt to gather the Ethernet related bindings in one file,
>> like it's done in the MMC and some other subsystems. It should save the trouble
>> of documenting several properties over and over in each binding document.

>> I have used the Embedded Power Architecture(TM) Platform Requirements (ePAPR)
>> standard as a base for the properties description, also documenting some ad-hoc
>> properties that have been introduced over time despite having direct analogs in
>> ePAPR.

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>> ---
>> The patch is against DaveM's 'net-next.git' repo and the DaVinci EMAC bindings
>> fix I've posted yesterday:

>> http://patchwork.ozlabs.org/patch/311854/

[...]

>> Index: net-next/Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
>> ===================================================================
>> --- net-next.orig/Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
>> +++ net-next/Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
>> @@ -4,13 +4,8 @@ Required properties:
>>   - compatible: should be "allwinner,sun4i-emac".
>>   - reg: address and length of the register set for the device.
>>   - interrupts: interrupt for the device
>> -- phy: A phandle to a phy node defining the PHY address (as the reg
>> -  property, a single integer).
>>   - clocks: A phandle to the reference clock for this device

>> -Optional properties:
>> -- (local-)mac-address: mac address to be used by this driver
>> -

> You should reference that this binding uses the common ethernet binding doc.

    Oh, I was hoping to avoid that like MMC subsys mostly managed to do (most 
MMC specific properties are only described once, without outside references to 
mmc.txt). OTOH, the MMC bindings handling is mostly centralized in the core 
code, while the Ethernet one is not, so you're probably right here...

>> Index: net-next/Documentation/devicetree/bindings/net/ethernet.txt
>> ===================================================================
>> --- /dev/null
>> +++ net-next/Documentation/devicetree/bindings/net/ethernet.txt
>> @@ -0,0 +1,20 @@
>> +The following properties are common to the Ethernet controllers:
>> +
>> +- local-mac-address: array of 6 bytes, specifies the MAC address that was
>> +  assigned to the network device;
>> +- mac-address: array of 6 bytes, specifies the MAC address that was last used by
>> +  the boot program; should be used in cases where the MAC address assigned to
>> +  the device by the boot program is different from the "local-mac-address"
>> +  property;
>> +- max-speed: number, specifies maximum speed in Mbit/s supported by the device;
>> +- phy-mode: string, operation mode of the PHY interface; supported values are
>> +  "mii", "gmii", "sgmii", "tbi", "rev-mii", "rmii", "rgmii", "rgmii-id",
>> +  "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii";

> Mark this as deprecated

    That's kind of wishful thinking at this point, as that's what the majority 
of drivers use. I'm unsure of the reasons why that was done, probably people 
just didn't read the proper specs...

> in favor of phy-connection-type

    That one is only used by the oldish PowerPC 'gianfar' driver.

> so it's use does not spread.

    I'm afraid that's too late, it has spread very far, so that 
of_get_phy_mode() handles that property, not "phy-connection-type".

>> +- phy-connection-type: the same as "phy-mode" property (but described in ePAPR);
>> +- phy-handle: phandle, specifies a reference to a node representing a PHY
>> +  device (this property is described in ePAPR);
>> +- phy: the same as "phy-handle" property (but actually ad-hoc one).

> Mark this as deprecated in favor of phy-handle.

    Here situation is more optimistic. Quite many drivers still use 
"phy-handle", though some use even more exotic props I didn't document here.

WBR, Sergei
