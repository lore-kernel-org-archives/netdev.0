From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch for 2.6.25? 2/3] smc91x driver: fix bug: print warning
 only in interrupt mode
Date: Sat, 12 Apr 2008 04:42:44 -0400
Message-ID: <48007604.9030602@garzik.org>
References: <200804110430.m3B4UbHn000436@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sonic.zhang@analog.com, cooloney@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41694 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756457AbYDLImr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 04:42:47 -0400
In-Reply-To: <200804110430.m3B4UbHn000436@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> http://blackfin.uclinux.org/gf/project/uclinux-dist/tracker/?action=TrackerItemEdit&tracker_item_id=3956
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> 
> On Fri, 28 Mar 2008 21:45:02 -0400 Jeff Garzik <jeff@garzik.org> wrote:
> 
>> akpm@linux-foundation.org wrote:
>>> From: Sonic Zhang <sonic.zhang@analog.com>
>>>
>>> http://blackfin.uclinux.org/gf/project/uclinux-dist/tracker/?action=TrackerItemEdit&tracker_item_id=3956
>>>
>>> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>>> Signed-off-by: Bryan Wu <cooloney@kernel.org>
>>> Cc: Jeff Garzik <jeff@garzik.org>
>>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>>> ---
>>>
>>>  drivers/net/smc91x.c |    2 ++
>>>  1 file changed, 2 insertions(+)
>>>
>>> diff -puN drivers/net/smc91x.c~smc91x-driver-fix-bug-print-warning-only-in-interrupt-mode drivers/net/smc91x.c
>>> --- a/drivers/net/smc91x.c~smc91x-driver-fix-bug-print-warning-only-in-interrupt-mode
>>> +++ a/drivers/net/smc91x.c
>>> @@ -1326,9 +1326,11 @@ static irqreturn_t smc_interrupt(int irq
>>>  	SMC_SET_INT_MASK(lp, mask);
>>>  	spin_unlock(&lp->lock);
>>>  
>>> +#ifndef CONFIG_NET_POLL_CONTROLLER
>>>  	if (timeout == MAX_IRQ_LOOPS)
>>>  		PRINTK("%s: spurious interrupt (mask = 0x%02x)\n",
>>>  		       dev->name, mask);
>>> +#endif
>>>  	DBG(3, "%s: Interrupt done (%d loops)\n",
>>>  	       dev->name, MAX_IRQ_LOOPS - timeout);
>> NAK
>>
>> Either this code is OK or it isn't.  This patch simply hides a problem 
>> inside a configuration the developer probably doesn't use.
>>
>> What's the _real_ problem?  Looking at the tracker, I'd guess that some 
>> events need to be masked, but are not?
>>
>> If the hardware is asserting events continually, the current code does 
>> the right thing -- keep processing interrupt events flagged, until (a) 
>> no more events asserted or (b) max loop count reached.
>>
>> So the question is to find out why you are hitting the timeout, and what 
>> to do about it.
> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/smc91x.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff -puN drivers/net/smc91x.c~smc91x-driver-fix-bug-print-warning-only-in-interrupt-mode drivers/net/smc91x.c
> --- a/drivers/net/smc91x.c~smc91x-driver-fix-bug-print-warning-only-in-interrupt-mode
> +++ a/drivers/net/smc91x.c
> @@ -1326,9 +1326,11 @@ static irqreturn_t smc_interrupt(int irq
>  	SMC_SET_INT_MASK(lp, mask);
>  	spin_unlock(&lp->lock);
>  
> +#ifndef CONFIG_NET_POLL_CONTROLLER
>  	if (timeout == MAX_IRQ_LOOPS)
>  		PRINTK("%s: spurious interrupt (mask = 0x%02x)\n",
>  		       dev->name, mask);
> +#endif
>  	DBG(3, "%s: Interrupt done (%d loops)\n",
>  	       dev->name, MAX_IRQ_LOOPS - timeout);
>  

applied


