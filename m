From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH 2.6.19-rc4-git10][PKT_SCHED] sch_htb: INIT_HLIST_NODE after hlist_del()
Date: Wed, 8 Nov 2006 07:36:45 +0100
Message-ID: <20061108063645.GA984@ff.dom.local>
References: <20061106113353.GA4829@ff.dom.local> <20061106094449.3b8253b9@freekitty> <20061107064943.GA998@ff.dom.local> <20061107095007.71c11b47@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S\. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:2971 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1754369AbWKHGaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 01:30:55 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061107095007.71c11b47@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 07, 2006 at 09:50:07AM -0800, Stephen Hemminger wrote:
> On Tue, 7 Nov 2006 07:49:43 +0100
> Jarek Poplawski <jarkao2@o2.pl> wrote:
...
> Your patch duplicated the code in hlist_del_init().  Why not do:
> 
> --- a/net/sched/sch_htb.c	2006-11-07 09:48:22.000000000 -0800
> +++ b/net/sched/sch_htb.c	2006-11-07 09:49:01.000000000 -0800
> @@ -1284,8 +1284,7 @@
>  						  struct htb_class, sibling));
>  
>  	/* note: this delete may happen twice (see htb_delete) */
> -	if (!hlist_unhashed(&cl->hlist))
> -		hlist_del(&cl->hlist);
> +	hlist_del_init(&cl->hlist);
>  	list_del(&cl->sibling);
>  
>  	if (cl->prio_activity)
> @@ -1333,8 +1332,7 @@
>  	sch_tree_lock(sch);
>  
>  	/* delete from hash and active; remainder in destroy_class */
> -	if (!hlist_unhashed(&cl->hlist))
> -		hlist_del(&cl->hlist);
> +	hlist_del_init(&cl->hlist);
>  
>  	if (cl->prio_activity)
>  		htb_deactivate(q, cl);
> 

I've understood you first suggestion. But after sending
my patch I've found it is also hiding a real problem
of excessive deletion in one and possibly more places.
So probably this should be done the right way and this
hlist_unhashed testing left in BUG_ON only... 

Cheers,
Jarek P. 
