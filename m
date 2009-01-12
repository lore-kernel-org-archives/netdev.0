From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 7/6] Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used
 jiffies in htb_dequeue()
Date: Mon, 12 Jan 2009 11:22:47 +0100
Message-ID: <496B19F7.4060909@trash.net>
References: <20081210093532.GA7926@ff.dom.local> <20081216.155722.144236025.davem@davemloft.net> <20081217070303.GA4577@ff.dom.local> <20081216.233801.26557633.davem@davemloft.net> <496AE9A5.9060507@trash.net> <20090112101047.GA5448@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60979 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbZALKWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 05:22:49 -0500
In-Reply-To: <20090112101047.GA5448@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Mon, Jan 12, 2009 at 07:56:37AM +0100, Patrick McHardy wrote:
>> Sorry, I dropped the ball on this one. I still think scheduling
>> a work-queue or something else running in process context to
>> kick the queue once the scheduler had a chance to run would
>> be a better solution. But Jarek's patches are an improvement
>> to the current situation, so no objections from me.
>>
> 
> Thanks for the review Patrick. As I wrote before, I'm not against
> using a workqueue here: it's logically better, but I still think
> this place is rather exception, so I'm not convinced we should
> care so much adding better solution, but also some overhead when
> cancelling this workqueue. But if it really bothers you, please
> confirm, and I'll do it.

It doesn't bother me :) I just think its the technical better
and also most likely code-wise cleaner solution to this problem.
Cancellation wouldn't be necessary since an unnecessary
netif_schedule() doesn't really matter.

It you don't mind adding the workqueue, I certainly would prefer
it, but I'm also fine with this patch. I don't have a HTB setup
or a testcase for this specific case, otherwise I'd simply do it
myself.

> BTW, I wonder if adding the old "too many
> events" warning back wouldn't be more useful here.

It would be good to notify the user and also have some indication
for this case when looking into bug reports. A counter or a (single)
printk would both be fine.

