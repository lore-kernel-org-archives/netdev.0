From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: add sparse annotation to ptype_seq_start/stop
Date: Sun, 20 Jan 2008 21:03:55 -0800
Message-ID: <20080121050355.GD7541@linux.vnet.ibm.com>
References: <20080120152146.70bc0b12@deepthought>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	josh@freedesktop.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:42578 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbYAUFEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 00:04:02 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0L40pgW009552
	for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 23:00:51 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0L53vxY097796
	for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 22:03:57 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0L53vME017658
	for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 22:03:57 -0700
Content-Disposition: inline
In-Reply-To: <20080120152146.70bc0b12@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 20, 2008 at 03:21:46PM -0800, Stephen Hemminger wrote:
> Get rid of some more sparse warnings.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Adding Josh to CC -- is __acquires() case-insensitive?  If not, this
needs to be __acquires(RCU) and __releases(RCU).

						Thanx, Paul

> --- a/net/core/dev.c	2008-01-20 14:25:00.000000000 -0800
> +++ b/net/core/dev.c	2008-01-20 14:25:48.000000000 -0800
> @@ -2543,6 +2543,7 @@ static void *ptype_get_idx(loff_t pos)
>  }
> 
>  static void *ptype_seq_start(struct seq_file *seq, loff_t *pos)
> +	__acquires(rcu)
>  {
>  	rcu_read_lock();
>  	return *pos ? ptype_get_idx(*pos - 1) : SEQ_START_TOKEN;
> @@ -2578,6 +2579,7 @@ found:
>  }
> 
>  static void ptype_seq_stop(struct seq_file *seq, void *v)
> +	__releases(rcu)
>  {
>  	rcu_read_unlock();
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
