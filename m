From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 01/10] Preparatory refactoring part 1.
Date: Mon, 01 Oct 2007 15:25:30 +0200
Message-ID: <4700F54A.6070408@trash.net>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <11910199771607-git-send-email-bugfood-ml@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32795 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbXJANZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 09:25:54 -0400
In-Reply-To: <11910199771607-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> Make a new function sfq_q_enqueue() that operates directly on the
> queue data. This will be useful for implementing sfq_change() in
> a later patch. A pleasant side-effect is reducing most of the
> duplicate code in sfq_enqueue() and sfq_requeue().
> 
> Similarly, make a new function sfq_q_dequeue().
> 
> Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
> ---
>  net/sched/sch_sfq.c |   72 +++++++++++++++++++++++++++------------------------
>  1 files changed, 38 insertions(+), 34 deletions(-)
> 
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 3a23e30..57485ef 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> 


The sfq_q_enqueue part looks fine.

>  
> -	sch->qstats.drops++;


A line in the changelog explaining that this was increased twice
would have been nice.

>  	sfq_drop(sch);
>  	return NET_XMIT_CN;
>  }
>  
> -
> -
> -
> -static struct sk_buff *
> -sfq_dequeue(struct Qdisc* sch)
> +static struct
> +sk_buff *sfq_q_dequeue(struct sfq_sched_data *q)


What is this function needed for?
