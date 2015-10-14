From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] net/mlx5_core: Fix internal error
 detection conditions
Date: Tue, 13 Oct 2015 19:46:37 -0700 (PDT)
Message-ID: <20151013.194637.203386807677265903.davem@davemloft.net>
References: <1444751049-2511-1-git-send-email-ogerlitz@mellanox.com>
	<1444751049-2511-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eli@mellanox.com, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbbJNCah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 22:30:37 -0400
In-Reply-To: <1444751049-2511-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 13 Oct 2015 18:44:06 +0300

> +	if (in_fatal(dev) && !health->sick) {
> +		health->sick = 1;
> +		print_health_info(dev);
> +		queue_work(health->wq, &health->work);
>  	}
>  }
>  
> diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
> index 41a3287..cd469b9 100644
> --- a/include/linux/mlx5/driver.h
> +++ b/include/linux/mlx5/driver.h
> @@ -393,6 +393,7 @@ struct mlx5_core_health {
>  	struct timer_list		timer;
>  	u32				prev;
>  	int				miss_counter;
> +	int				sick;
>  	struct workqueue_struct	       *wq;
>  	struct work_struct		work;
>  };
> -- 
> 2.3.7
> 

Please use "bool" and true/false for boolean states.
