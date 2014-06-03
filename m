From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] sh_eth: use RNC mode for R8A7790/R87791
Date: Wed, 04 Jun 2014 00:02:19 +0400
Message-ID: <538E29CB.4020008@cogentembedded.com>
References: <538CD19B.5060208@cogentembedded.com>	<20140602.134915.1162774321657125992.davem@davemloft.net>	<538CE4CA.4090301@cogentembedded.com> <20140602.140504.1151986761253502538.davem@davemloft.net> <538CE9EB.1010506@cogentembedded.com> <538CFA08.3010302@cogentembedded.com> <538DAF3A.2020903@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@codethink.co.uk, netdev@vger.kernel.org,
	nobuhiro.iwamatsu.yj@renesas.com, magnus.damn@opensource.se,
	horms@verge.net.au, yoshihiro.shimoda.uh@renesas.com,
	cm-hiep@jinso.co.jp, linux-sh@vger.kernel.org
To: Ben Dooks <ben.dooks@codethink.co.uk>,
	David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <538DAF3A.2020903@codethink.co.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/03/2014 03:19 PM, Ben Dooks wrote:

>>>>>>>       Looks like the early SH2/3 SoCs didn't implement the whole
>>>>>>> register.
>>>>>>> Despite that, sh_eth_dev_init() always writes to this register... :-/
>>>>>>> So far, the RMCR.RNC bit was mostly set for the Gigabit-capable
>>>>>>> controllers, however that rule wasn't strictly followed. Well, this
>>>>>>> driver is still a mess, and it's hard to deal with it without the
>>>>>>> necessary documentation.

>>>>>> Why don't we therefore:

>>>>>> 1) Skip the register write if the per-chip value is zero.

>>>>>      I rather thought about not writing when the register is not
>>>>>      implemented.
>>>>> I'll probably look into this when I have time.

>>>>>> 2) Add the RNC bit to all of the gigabit capable controllers.

>>>>>      I probably misspoke -- all the Gigabit controllers already have it
>>>>> set, it's just that some 100 MBbps ones have it set, but most
>>>>> don't.

>>>> So these chips that do not implement the register, they only process
>>>> one RX descriptor at a time until the interrupt handler re-enables
>>>> DMA receive?

>>>      I just don't know. Looks like the driver is broken on SH2/3 even
>>> more than
>>> I thought: it always reads the EDRRR register in sh_eth_rx() trying to
>>> understand if the reception has been stopped but that register doesn't
>>> seem to
>>> exist on SH2/3. Moreover, sh_eth_interrupt() reads EESR in order to
>>> determine
>>> the interrupt status but that register doesn't seem to exist on SH2/3
>>> either!

>>     OK, I've chased down the commit that broke SH2/3 support 3+ years
>> ago; here it is:

>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=4a55530f38e4eeee3afb06093e81309138fe8360

>>     All the registers I've mentioned did exist on SH2/3, they just got
>> missed in the mapping arrays.

> I suppose it would be a good idea to submit a patch to add these then.

    Not that I'm supposed to fix the old SH machines now but I've just posted 
the patch. :-)

WBR, Sergei

