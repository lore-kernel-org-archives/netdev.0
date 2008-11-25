From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2] pkt_sched: sch_drr: Fix drr_dequeue() loop
Date: Tue, 25 Nov 2008 12:42:20 +0100
Message-ID: <492BE49C.6060408@trash.net>
References: <20081124125150.GB16755@ff.dom.local>	<492AA96C.6000807@trash.net>	<20081124134516.GD16755@ff.dom.local> <20081124.154720.219944704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56340 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbYKYLma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 06:42:30 -0500
In-Reply-To: <20081124.154720.219944704.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Things seem to have settled, thus I have applied Patrick's version
> of the fix.

Thanks.

> But I encourage people to add the necessary framework such that
> such unwanted configurations can be in fact detected at ->init()
> time and thus properly warned about.
> 
> Silent packet dropping really upsets users.

The packets won't be dropped, the qdisc will simply wait until the
throttled inner qdisc becomes active again.

Refusing incorrect changes in ->init() is not easy because at least
HFSC can switch between work-conserving and non-work-conserving
through ->change(), so the upper qdisc would have to be able to
perform validation before the change is made. This is additionally
complicated by the fact that (in case of HFSC) it can't be determined
by looking only at the class that is currently changed, the use
of a upper-limit curve on any class makes it non-work-conserving.

Perhaps its best to ignore this special case and always treat HFSC
as non-work-conserving, I haven't seen a configuration which uses
a hierarchical qdisc as inner qdisc so far.

