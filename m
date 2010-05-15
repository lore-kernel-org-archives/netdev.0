From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: TSC unstable due to TSC halts in idle?
Date: Sat, 15 May 2010 11:54:15 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005151139280.16599@ask.diku.dk>
References: <Pine.LNX.4.64.1005142208290.6220@ask.diku.dk>
 <AANLkTimeXEaUnzSBuilbQLHj_oho3ia9EgyPGpB7vJRI@mail.gmail.com>
 <1273878957.2825.175.camel@sbs-t61.sc.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: john stultz <johnstul@us.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Brown, Len" <len.brown@intel.com>,
	"Li, Shaohua" <shaohua.li@intel.com>, "hawk@comx.dk" <hawk@comx.dk>
To: Suresh Siddha <suresh.b.siddha@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:38768 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753103Ab0EOJyV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 May 2010 05:54:21 -0400
In-Reply-To: <1273878957.2825.175.camel@sbs-t61.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 14 May 2010, Suresh Siddha wrote:
> On Fri, 2010-05-14 at 15:28 -0700, john stultz wrote:
>> On Fri, May 14, 2010 at 1:13 PM, Jesper Dangaard Brouer <hawk@diku.dk> wrote:
>>> I want to know, if its safe to enable the TSC clocksource, when the
>>> kernel reports:
>>>  "Marking TSC unstable due to TSC halts in idle"
>>>
>>> The system selects HPET (in current_clocksource), but I can still see
>>> TSC as an available clocksource (in
>>> /sys/devices/system/clocksource/clocksource0/available_clocksource).
>>>
>>> Is it safe to enable TSC manually (by changing current_clocksource)?
>>> (my workload is 10Git/s routing, cannot survive with a slow clock)
>>>
>>>
>>> Any trick to avoid this? (e.g. kernel config setting, or a /sys/ setting
>>> which changes the minimum P-state?)
>>
>> Might try booting with the max-cstate=1 option.
>
> Jesper mentioned that it is xeon 5550. TSC's for that processor doesn't
> stop in idle.

Thanks, then it should be safe to force using TSC, even on this older 
kernel.


> Perhaps he is using an older kernel which doesn't detect this fact. 
> Jesper, more recent kernels should be able to use TSC as the 
> clocksource.

Guess this it the problem. As I'm running a standard Debian compiled 
kernel 2.6.26-2-amd64 (which comes with Debian lenny).  I'm not going to 
run with this kernel in production, as it doesn't have multiqueue support 
and doesn't support the NICs I'm using.

I'm already annoyed with this old kernel, as it doesn't support any of the 
NICs in the machine, not even the build in NICs in the HP370 G6 server.

I'll boot a new kernel on the machine Monday, and I'll complain if it 
didn't solve the issue, else consider this issue solved "in a newer kernel 
version".

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
