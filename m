From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm][v2] ratelimit rewrite
Date: Thu, 8 May 2008 12:25:14 -0700
Message-ID: <20080508122514.63482a06.akpm@linux-foundation.org>
References: <20080506022558.GA2904@darkstar.te-china.tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paulmck@us.ibm.com, joe@perches.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34084 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751185AbYEHT0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 15:26:47 -0400
In-Reply-To: <20080506022558.GA2904@darkstar.te-china.tietoenator.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 May 2008 10:25:58 +0800
Dave Young <hidave.darkstar@gmail.com> wrote:

>  static inline void rcu_enter_nohz(void)
>  {
> +	static DEFINE_RATELIMIT_STATE(rs, 10 * HZ, 1);
>  	smp_mb(); /* CPUs seeing ++ must see prior RCU read-side crit sects */
>  	__get_cpu_var(rcu_dyntick_sched).dynticks++;
> -	WARN_ON_SECS(__get_cpu_var(rcu_dyntick_sched).dynticks & 0x1, 10);
> +	WARN_ON_RATELIMIT(__get_cpu_var(rcu_dyntick_sched).dynticks & 0x1, &rs);
>  }
>  
>  static inline void rcu_exit_nohz(void)
>  {
> +	static DEFINE_RATELIMIT_STATE(rs, 10 * HZ, 1);
>  	__get_cpu_var(rcu_dyntick_sched).dynticks++;
>  	smp_mb(); /* CPUs seeing ++ must see later RCU read-side crit sects */
> -	WARN_ON_SECS(!(__get_cpu_var(rcu_dyntick_sched).dynticks & 0x1), 10);
> +	WARN_ON_RATELIMIT(!(__get_cpu_var(rcu_dyntick_sched).dynticks & 0x1),
> +			&rs);

Why are we altering the RCU code in this patch, btw?  It seems fairly
random that we happened to choose these particular WARN_ONs.  Do they have
a history of triggering?

