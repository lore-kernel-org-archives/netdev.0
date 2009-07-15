From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 1/3] net: serialize hrtimer callback in sched_cbq
Date: Wed, 15 Jul 2009 11:56:55 +0200
Message-ID: <4A5DA7E7.8020303@hartkopp.net>
References: <20090709215606.526259917@linutronix.de>	<20090712.135555.207096388.davem@davemloft.net>	<alpine.LFD.2.00.0907141040350.2777@localhost.localdomain> <20090714.090055.56906831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net, peterz@infradead.org
To: David Miller <davem@davemloft.net>, tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:13746 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbZGOJ5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 05:57:09 -0400
In-Reply-To: <20090714.090055.56906831.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
> Date: Tue, 14 Jul 2009 10:55:14 +0200 (CEST)
> 
>> David,
>>
>> On Sun, 12 Jul 2009, David Miller wrote:
>>
>>> What should probably happen is that the hrtimer merely fires off work
>>> at software interrupt context (perhaps a tasklet or similar), and that
>>> software interrupt code take the qdisc's root lock throughout it's
>>> execution.
>> Sigh, I almost expected that the removal of the callback modes will
>> fire back some day.
> 
> Well this makes hrtimers decidedly less useful for networking and we
> have a ton of bugs right now, basically in every hrtimer used by the
> networking currently.

The CAN stuff is clean in this topic. See below.

> 
> The only way we can use them, as things currently stand, is as
> triggers for softirq work.
> 
> Is it really that troublesome to provide this kind of facility
> generically, rather than having various subsystems replicate such code
> where they want to use hrtimers and are restricted to softirqs?

Indeed this had been my concerns also, when i moved the hrtimer usage in a CAN
protocol to use tasklets.

("can: update can-bcm for hrtimer hardirq callbacks")
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=6e5c172cf7ca1ab878cc6a6a4c1d52fef60f3ee0

due to

("hrtimer: removing all ur callback modes")
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=ca109491f612aab5c8152207631c0444f63da97f

I was not very amused that time and wanted to NACK that change, but Linus said:

"Quite frankly, your NAK doesn't matter.
We've had too many bugs in hrtimers. They _will_ get simplified."
(http://lkml.indiana.edu/hypermail/linux/kernel/0812.1/00218.html)

Thomas, is there chance to get this nice simple possibility back to invoke at
least a hrtimer for SOFT_IRQ context additional to the current functionality??

I would expect this to save lot's of tasklet code that is - and will be -
created due to the lack of the hrtimers softirq capability ...

FWIK there were really many callback modes before (per-cpu stuff and so), that
were probably too much. But having a SOFT_IRQ callback mode again would really
help.

Regards,
Oliver

