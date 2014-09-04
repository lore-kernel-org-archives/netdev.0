From: Zhi Li <lznuaa@gmail.com>
Subject: Re: [Patch net-next 08/11] net:fec: change FEC alignment to 64 bytes
 for ARM platform
Date: Thu, 4 Sep 2014 09:17:20 -0500
Message-ID: <CAHrpEqQYUTL8ux9dwnzogihdVXhDs=W25nZthpjBAVzcEEzXUw@mail.gmail.com>
References: <1409776697-1536-1-git-send-email-Frank.Li@freescale.com>
	<1409776697-1536-9-git-send-email-Frank.Li@freescale.com>
	<063D6719AE5E284EB5DD2968C1650D6D17487196@AcuExch.aculab.com>
	<e50c6383dc184566846e190026d1186a@BLUPR03MB373.namprd03.prod.outlook.com>
	<063D6719AE5E284EB5DD2968C1650D6D174872BE@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:56926 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbaIDORW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 10:17:22 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174872BE@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 4, 2014 at 4:18 AM, David Laight <David.Laight@aculab.com> wrote:
> From: fugang.duan@freescale.com
>> >From: Frank Li
>> >> From: Fugang Duan <B38611@freescale.com>
>> >>
>> >> Since enet-avb has 64 bytes alignment limitation for rx DMA transfer.
>> >> The previous enet IP for ARM platform has 16 bytes alignment for tx
>> >> DMA transfer.
>> >
>> >Do you mean rx or tx here? or both??
>> >
>> >And can we beat up the hardware designers to stop these restrictions on rx
>> >(in particular) ethernet buffer alignments?
>> >A device isn't suitable for ethernet unless is can write the destination
>> >mac address to a 4n+2 boundary.
>> >
>> >     David
>> >
>> Hi, David,
>>
>> For previous enet IP there has 16 bytes data buffer alignment limitation for tx & rx DMA transfer.
>> For imx6sx enet-avb IP, there has 64 bytes data buffer alignment limitation for rx DMA transfer, byte
>> alignment for tx data
>> Buffer for DMA transfer.
>>
>> I think rx data buffer alignment limitation don't introduce performance drop, is not complex for sw
>> implemention. Anyway,
>> We can request IC designer to remove the limitation for future chips.
>
> The 'problem' is that you need the IP header to be 32bit aligned.
> If the dma buffer has to be aligned then the code either has to do an expensive
> misaligned copy of the entire frame (at some point the entire frame is almost
> certainly all copied into an aligned buffer), or take the hit of misaligned
> memory accesses (which might have to be emulated with byte transfers).
>
> The rx buffer can be aligned provided the hardware skips (or writes junk to)
> the first two bytes.

ENET IP have feature to add additional 2 byte when save data to memory.

RX FIFO Shift-16
When this field is set, the actual frame data starts at bit 16 of the
first word read from the RX FIFO aligning
the Ethernet payload on a 32-bit boundary.
NOTE: This function only affects the FIFO storage and has no influence
on the statistics, which use the
actual length of the frame received.
0 Disabled.
1 Instructs the MAC to write two additional bytes in front of each
frame received into the RX FIFO.

i.MX6SX,
          Remove TX alignment requirement.
          But RX and DMA BD address is 64byte aligment.


best regards
Frank Li



>
>         David
>
>
>
