From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next 2/2] net: avoid calling sched_clock when LLS
 is off
Date: Fri, 28 Jun 2013 16:38:40 +0200
Message-ID: <20130628143840.GS6123@two.firstfloor.org>
References: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com>
 <20130628125934.14419.38109.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Cody P Schafer <devel-lists@codyps.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130628125934.14419.38109.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/fs/select.c b/fs/select.c
> index 79b876e..3654075 100644
> --- a/fs/select.c
> +++ b/fs/select.c
> @@ -402,7 +402,7 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>  	poll_table *wait;
>  	int retval, i, timed_out = 0;
>  	unsigned long slack = 0;
> -	unsigned int ll_flag = POLL_LL;
> +	unsigned int ll_flag = ll_get_flag();

Is that a global flag? That's still the wrong level. It should
look at something in the file descriptor (preferably without
fetching any new cache lines)

-Andi

>  
> +static inline unsigned int ll_get_flag(void)
> +{
> +	return sysctl_net_ll_poll ? POLL_LL : 0;
> +}
