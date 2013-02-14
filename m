From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCHi v2] net: sh_eth: Add support of device tree probe
Date: Thu, 14 Feb 2013 12:18:32 +0900
Message-ID: <CABMQnVKYt+WNcDoUG20zQaoXBxMwbcdyW-CeMqdfqE+=gdsjsg@mail.gmail.com>
References: <1360803091-26400-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <CANqRtoQ_+eZFc-n0juBQP+BofR-bmVmEW_aVZdDP-vyr_aW5Kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	kda@linux-powerpc.org, horms+renesas@verge.net.au
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:57074 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205Ab3BNDTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 22:19:05 -0500
Received: by mail-la0-f45.google.com with SMTP id er20so1851110lab.4
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2013 19:19:02 -0800 (PST)
In-Reply-To: <CANqRtoQ_+eZFc-n0juBQP+BofR-bmVmEW_aVZdDP-vyr_aW5Kw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 14, 2013 at 10:47 AM, Magnus Damm <magnus.damm@gmail.com> wrote:
> Hi Iwamatsu-san,
>
> On Thu, Feb 14, 2013 at 9:51 AM, Nobuhiro Iwamatsu
> <nobuhiro.iwamatsu.yj@renesas.com> wrote:
>> This adds support of device tree probe for Renesas sh-ether driver.
>>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>>
>> ---
>> V2: - Removed ether_setup().
>>     - Fixed typo from "sh-etn" to "sh-eth".
>>         - Removed "needs-init" and sh-eth,endian from definition of DT.
>>         - Changed "sh-eth,edmac-endian" instead of "sh-eth,edmac-big-endain"
>>           in definition of DT.
>>
>>  Documentation/devicetree/bindings/net/sh_ether.txt |   41 +++++
>>  drivers/net/ethernet/renesas/sh_eth.c              |  156 +++++++++++++++++---
>>  2 files changed, 173 insertions(+), 24 deletions(-)
>>  create mode 100644 Documentation/devicetree/bindings/net/sh_ether.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/sh_ether.txt b/Documentation/devicetree/bindings/net/sh_ether.txt
>> new file mode 100644
>> index 0000000..7415e54
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/sh_ether.txt
>> @@ -0,0 +1,41 @@
>> +* Renesas Electronics SuperH EMAC
>> +
>> +This file provides information, what the device node
>> +for the sh_eth interface contains.
>> +
>> +Required properties:
>> +- compatible:                   "renesas,sh-eth";
>> +- interrupt-parent:             The phandle for the interrupt controller that
>> +                                services interrupts for this device.
>> +- reg:                          Offset and length of the register set for the
>> +                                device.
>> +- interrupts:                   Interrupt mapping for the sh_eth interrupt
>> +                                sources (vector id).
>> +- phy-mode:                     String, operation mode of the PHY interface.
>> +- sh-eth,register-type:         String, register type of sh_eth.
>> +                                Please select "gigabit", "fast-sh4" or
>> +                                "fast-sh3-sh2".
>> +- sh-eth,phy-id:                PHY id.
>> +
>> +Optional properties:
>> +- local-mac-address:            6 bytes, mac address
>> +- sh-eth,no-ether-link:         Set link control by software. When device does
>> +                                not support ether-link, set.
>> +- sh-eth,ether-link-active-low: Set link check method.
>> +                                When detection of link is treated as active-low,
>> +                                set.
>> +- sh-eth,edmac-big-endian:      Set big endian for sh_eth dmac.
>> +                                It work as little endian when this is not set.
>> +- sh-etn,needs-init:            Initialization flag.
>> +                                When initialize device in probing device, set.
>
> I believe the above still says "sh-etn". Also, it is unclear why you
> want this flag at all since it is not used to describe the hardware.
>

yes, I forgot to delete this.
I will fix.

regards,
  Nobuhiro

-- 
Nobuhiro Iwamatsu
