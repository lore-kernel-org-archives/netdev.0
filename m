From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] Doc: Fix wrong API example usage of call_rcu().
Date: Fri, 6 Mar 2009 21:49:59 -0800
Message-ID: <20090307054959.GE10625@linux.vnet.ibm.com>
References: <20090306132732.15896.96543.stgit@localhost.localdomain> <20090306132738.15896.2226.stgit@localhost.localdomain>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:45752 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147AbZCGFuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Mar 2009 00:50:03 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n275koEA019222
	for <netdev@vger.kernel.org>; Sat, 7 Mar 2009 00:46:50 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n275o0pv173442
	for <netdev@vger.kernel.org>; Sat, 7 Mar 2009 00:50:00 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n275nx3f005646
	for <netdev@vger.kernel.org>; Sat, 7 Mar 2009 00:50:00 -0500
Content-Disposition: inline
In-Reply-To: <20090306132738.15896.2226.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 06, 2009 at 02:27:38PM +0100, Jesper Dangaard Brouer wrote:
> At some point the API of call_rcu() changed from three parameters
> to two parameters, correct the documentation.
> 
> One confusing thing in RCU/listRCU.txt, which is NOT fixed in this patch,
> is that no reason or explaination is given for using call_rcu() instead of
> the normal synchronize_rcu() call.

Good catch!!!  Indeed, call_rcu() did take three arguments at one time,
like back in 2.5 days...

On the use of call_rcu() vs. synchronize_rcu(), the two possible reasons
called out in question 8 in Documentation/RCU/checklist.txt are:

1.	Update performance is important.

2.	Updaters cannot block.

I would welcome a patch to this file discussing this.

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> ---
> 
>  Documentation/RCU/listRCU.txt |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/RCU/listRCU.txt b/Documentation/RCU/listRCU.txt
> index 1fd1753..4349c14 100644
> --- a/Documentation/RCU/listRCU.txt
> +++ b/Documentation/RCU/listRCU.txt
> @@ -118,7 +118,7 @@ Following are the RCU equivalents for these two functions:
>  		list_for_each_entry(e, list, list) {
>  			if (!audit_compare_rule(rule, &e->rule)) {
>  				list_del_rcu(&e->list);
> -				call_rcu(&e->rcu, audit_free_rule, e);
> +				call_rcu(&e->rcu, audit_free_rule);
>  				return 0;
>  			}
>  		}
> @@ -206,7 +206,7 @@ RCU ("read-copy update") its name.  The RCU code is as follows:
>  				ne->rule.action = newaction;
>  				ne->rule.file_count = newfield_count;
>  				list_replace_rcu(e, ne);
> -				call_rcu(&e->rcu, audit_free_rule, e);
> +				call_rcu(&e->rcu, audit_free_rule);
>  				return 0;
>  			}
>  		}
> @@ -283,7 +283,7 @@ flag under the spinlock as follows:
>  				list_del_rcu(&e->list);
>  				e->deleted = 1;
>  				spin_unlock(&e->lock);
> -				call_rcu(&e->rcu, audit_free_rule, e);
> +				call_rcu(&e->rcu, audit_free_rule);
>  				return 0;
>  			}
>  		}
> 
