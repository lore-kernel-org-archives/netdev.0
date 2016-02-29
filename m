From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 29 Feb 2016 15:04:15 -0800
Message-ID: <56D4CE6F.9040702@hurleysoftware.com>
References: <56D1E8B6.6090003@hurleysoftware.com>
 <1456638957.3676.12.camel@gmail.com>
 <20160228170109.GA16322@electric-eye.fr.zoreil.com>
 <1456721889.3488.67.camel@gmail.com> <56D45DAF.5070709@hurleysoftware.com>
 <1456759153.648.61.camel@edumazet-ThinkPad-T530>
 <56D469B2.2070707@hurleysoftware.com>
 <1456762914.648.76.camel@edumazet-ThinkPad-T530>
 <56D48869.1000106@hurleysoftware.com>
 <1456770279.648.85.camel@edumazet-ThinkPad-T530>
 <56D493A5.403@hurleysoftware.com> <alpine.DEB.2.11.1602292009430.3638@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Mike Galbraith <umgwanakikbuti@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1602292009430.3638@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/29/2016 11:14 AM, Thomas Gleixner wrote:
> On Mon, 29 Feb 2016, Peter Hurley wrote:
>> On 02/29/2016 10:24 AM, Eric Dumazet wrote:
>>>> Just to be clear
>>>>
>>>> 		if (time_before(jiffies, end) && !need_resched() &&
>>>> 		    --max_restart)
>>>> 			goto restart;
>>>>
>>>> aborts softirq *even if 0ns have elapsed*, if NET_RX has woken a process.
>>>
>>> Sure, now remove the 1st and 2nd condition.
>>
>> Well just removing the 2nd condition has everything working fine,
>> because that fixes the priority inversion.
> 
> No. It does not fix anything. It hides the shortcomings of the driver.
>  
>> However, when system resources are _not_ contended, it makes no
>> sense to be forced to revert to ksoftirqd resolution, which is strictly
>> intended as fallback.
> 
> No. You claim it is simply because your driver does not handle that situation
> properly.
>  
>> Or flipping your argument on its head, why not just _always_ execute
>> softirq in ksoftirqd?
> 
> Which is what that change effectivley does. And that makes a lot of sense,
> because you get the softirq load under scheduler control and do not let the
> softirq run as a context stealing entity which is completely uncontrollable by
> the scheduler.

Ok, fair enough.

However, charging [in the scheduler sense] very lightweight DMA completion for
one subsystem collectively with very heavyweight NET_RX (doing garbage collection
in softirq!) is hardly ideal.

The alternative being threaded interrupt handlers (which are essentially treated
as 0.000000 scheduler cost).

I just want to make sure that's the conscious choice being made, when the
patches for converting from tasklet to threaded irq start hitting subsystem
maintainers.

Regards,
Peter Hurley
