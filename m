From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_trie: rcu_assign_pointer warning fix
Date: Mon, 11 Feb 2008 17:16:45 -0800 (PST)
Message-ID: <20080211.171645.74019568.davem@davemloft.net>
References: <20080211165954.2f1b3a9b@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@us.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36544
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752843AbYBLBQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 20:16:14 -0500
In-Reply-To: <20080211165954.2f1b3a9b@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 11 Feb 2008 16:59:54 -0800

linux-kernel added to CC:, any change to generic kernel infrastructure
should be posted there

> Eliminate warnings when rcu_assign_pointer is used with unsigned long.
> It is reasonable to use RCU with non-pointer values so allow it for general
> use.  Add a comment to explain the if test.
> 
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
