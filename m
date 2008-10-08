From: Divy Le Ray <divy@chelsio.com>
Subject: Re: cxgb3 - fix race in EEH
Date: Wed, 08 Oct 2008 16:10:53 -0700
Message-ID: <48ED3DFD.2010204@chelsio.com>
References: <20081008.155850.182279915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:28263 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754416AbYJHXLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 19:11:36 -0400
In-Reply-To: <20081008.155850.182279915.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> I've applied this patch to net-next-2.6, BUT...
>
> You should show some signs of life and address the things
> Andrew Morton asked you about when you posted this patch.
>
> His questions and comments are included for your reference:
>
> ----------------------------------------
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
> ----------------------------------------
>   

Hi Dave,

I've got a series of patches almost ready to go against net-next-2.6 - 
hopefully within the next hour, and it includes a fix for this.
I was hoping to push the patches earlier this week, thus replying to 
Andrew's concerns. It's obviously taking longer than expected to get 
these patches out. I should have answered Andrew nonetheless.
The patch series will integrate Andrew'suggestions.

Cheers,
Divy

