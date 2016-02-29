From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 29 Feb 2016 07:58:44 -0800
Message-ID: <56D46AB4.6060805@hurleysoftware.com>
References: <56D1E8B6.6090003@hurleysoftware.com>
 <1456638957.3676.12.camel@gmail.com>
 <20160228170109.GA16322@electric-eye.fr.zoreil.com>
 <1456721889.3488.67.camel@gmail.com> <56D45DAF.5070709@hurleysoftware.com>
 <1456760443.3488.151.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456760443.3488.151.camel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/29/2016 07:40 AM, Mike Galbraith wrote:
> On Mon, 2016-02-29 at 07:03 -0800, Peter Hurley wrote:
> 
>>> If I'm listening properly, the root cause is that there is a timing
>>> constraint involved, which is being exposed because one softirq raises
>>> another (ew).
>>
>> Not the case. The softirq is raised from interrupt.
> 
> Yeah, saw that on re-read.
> 
>> Before Eric's change, when an interrupt raises a new softirq
>> while processing another softirq, the new softirq is immediately
>> processed *after the existing softirq completes*.
> 
> Not necessarily, Eric only changed it from an arbitrary count to an
> arbitrary time, so your irq could just as well land when there's no
> count left and be up the same creek.

Your misreading the softirq abort logic:
neither 2ms nor a fixed number of loops has elapsed.

All that's happened is the first loop of NET_RX softirq has woken a
process; that is sufficient to abort softirq and defer it for ksoftirqd.

That's why I'm saying this is a priority inversion, and one that
will happen a lot.


> I was more infatuated by the constraint that's left dangling in the
> breeze any time processing is deferred to ksoftirqd.
> 
> 	-Mike
> 
