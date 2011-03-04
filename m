From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v3)
Date: Thu, 3 Mar 2011 16:03:43 -0800
Message-ID: <20110303160343.71c55274@nehalam>
References: <20110228171738.2cc8c9a0@nehalam>
	<1299168235.2983.116.camel@edumazet-laptop>
	<20110303084839.3ae312ed@nehalam>
	<1299191333.2547.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33716 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758917Ab1CDADr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 19:03:47 -0500
In-Reply-To: <1299191333.2547.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Mar 2011 23:28:53 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Here there is the problem of *pp = cl->next (possibly NULL)
> 
> 		maybe use
> 
> 	for (pp = &grp->slots[j]; (cl = *pp) != NULL;) {
> 		if (cl->qdisc->q.len)
> 			qfq_deactivate_class(...);
> 		else
> 			pp = &cl->next;
> 	}
> 

I think changing slots from open coded linked list
to double linked list (list_for_each) would be clearer
and avoid these kind of bugs. That is what DRR does.

-- 
