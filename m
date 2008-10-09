From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 2.6.28 1/1] cxgb3 - fix race in EEH
Date: Wed, 08 Oct 2008 17:41:52 -0700
Message-ID: <48ED5350.6010502@chelsio.com>
References: <20080926000528.11959.63712.stgit@speedy5> <20081002180011.16254a4e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:26759 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756224AbYJIAm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 20:42:28 -0400
In-Reply-To: <20081002180011.16254a4e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Thu, 25 Sep 2008 17:05:28 -0700
> Divy Le Ray <divy@chelsio.com> wrote:
>
>   
>> A SGE queue set timer might access registers while in EEH recovery,
>> triggering an EEH error loop. Stop all timers early in EEH process.
>>     
>
> <looks>
>
> It's deeply weird that t3_reset_qset() does
>
> 	memset(&q->tx_reclaim_timer, 0, sizeof(q->tx_reclaim_timer));
>
> There are lots of things in the timer_list which the driver has no
> business modifying.  For example, this might break the metadata in
> Thomas's debugobjects stuff, which attempts to catch things being done
> in the wrong order (I don't think it will, but still...).
>
> Rerunning init_timer() should repair the damage, but I suspect a simple
>
> 	q->tx_reclaim_timer.function = NULL;	/* explanation goes here */
>
> would suffice here.
>
>
> t3_sge_alloc_qset() could use the newer setup_timer().
>
>   
Hi Andrew,

Your suggestion is implemented in the first patch of the series I just 
posted.
I apologize for the delayed reply.

Cheers,
Divy
