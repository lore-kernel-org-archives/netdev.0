From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] fib_trie: rcu_assign_pointer warning fix
Date: Mon, 11 Feb 2008 17:27:41 -0800
Message-ID: <20080212012741.GD29254@linux.vnet.ibm.com>
References: <20080211165954.2f1b3a9b@extreme>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:55322 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbYBLB1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 20:27:43 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1C1RhlC016276
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 20:27:43 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1C1RhVV216600
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 18:27:43 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1C1Rgs5010866
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 18:27:42 -0700
Content-Disposition: inline
In-Reply-To: <20080211165954.2f1b3a9b@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 11, 2008 at 04:59:54PM -0800, Stephen Hemminger wrote:
> Eliminate warnings when rcu_assign_pointer is used with unsigned long.
> It is reasonable to use RCU with non-pointer values so allow it for general
> use.  Add a comment to explain the if test.

Good catch!!!  (An apologies for the hassle!!!)

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ---
>  include/linux/rcupdate.h |   13 +++++++------
>  1 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> index 37a642c..c44ac87 100644
> --- a/include/linux/rcupdate.h
> +++ b/include/linux/rcupdate.h
> @@ -172,14 +172,15 @@ struct rcu_head {
>   * structure after the pointer assignment.  More importantly, this
>   * call documents which pointers will be dereferenced by RCU read-side
>   * code.
> + *
> + * If value is the NULL (constant 0), then no barrier is needed.
>   */
> 
> -#define rcu_assign_pointer(p, v) \
> -	({ \
> -		if (!__builtin_constant_p(v) || \
> -		    ((v) != NULL)) \
> -			smp_wmb(); \
> -		(p) = (v); \
> +#define rcu_assign_pointer(p, v)			\
> +	({						\
> +		if (!(__builtin_constant_p(v) && v))	\
> +			smp_wmb();			\
> +		(p) = (v);				\
>  	})
> 
>  /**
> -- 
> 1.5.3.8
> 
