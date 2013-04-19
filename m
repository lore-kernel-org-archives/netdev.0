From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: net/macb: clear tx/rx completion flags in ISR
Date: Fri, 19 Apr 2013 09:48:43 +0200
Message-ID: <5170F6DB.6030500@atmel.com>
References: <5170D276.6070208@yahoo.es> <20130419073058.GA660@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ludovic Desroches <ludovic.desroches@atmel.com>
To: Steffen Trumtrar <s.trumtrar@pengutronix.de>,
	Hein Tibosch <hein_tibosch@yahoo.es>, <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:59163 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756896Ab3DSHsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 03:48:50 -0400
In-Reply-To: <20130419073058.GA660@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2013 09:30 AM, Steffen Trumtrar :
> Hi Hein,
> 
> On Fri, Apr 19, 2013 at 01:13:26PM +0800, Hein Tibosch wrote:
>> Hi Steffen,
>>
>>> At least in the cadence IP core on the Xilinx Zynq SoC the TCOMP/RCOMP flags
>>> are not auto-cleaned. As these flags are evaluated, they need to be cleaned.
>>
>> This patch does not work for at least the AVR32 platform. Both RCOMP/RCOMP
>> are cleared by *reading* the ISR and writing them would be fatal.
>>
> 
> :-(
> 
>> Could you tell me the version of the macb of Xilinx Zynq?
>>
>>     u32 version = (macb_readl(bp, MID) & ((1 << MACB_REV_SIZE) - 1))
>>             | MACB_GREGS_VERSION;
>>
>> On an AP7000 it reads as 0x0000010D
>>
> 
> This gives me 0x00000119. The TRM says it is version r1p23.
> 
>> I am thinking of making a patch like:
>>
>>     if (bp->version >= xxx)
>>         macb_writel(bp, ISR, MACB_BIT(TCOMP));
>>
>>     if (bp->version >= xxx)
>>         macb_writel(bp, ISR, MACB_BIT(RCOMP));
>>
>> which would make it work on both platforms.

Well, keep in mind that it is the hot path: It can harm the performance
if too much tests are performed...

> The documentation I have is a little bit confusing in that regard.
> The cadence datasheet says, this register is R/W, the Xilinx datasheet says,
> it is "normaly RO", but the programming guide explicitely mentions clearing
> the bit by writing to it.
> It seems, that something like your patch is inevitable.

I also had bad feedbacks concerning this patch. Maybe we should take
more time to validate this change: event it is in net-next, maybe we
should revert it for the moment...

Best regards,
-- 
Nicolas Ferre
