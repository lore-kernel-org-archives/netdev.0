From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] net: remove the unnecessary list_del
Date: Mon, 25 Feb 2013 17:04:23 +0800
Message-ID: <512B2917.4010909@cn.fujitsu.com>
References: <512AF088.5040206@cn.fujitsu.com> <20130225.003931.1364384031279092217.davem@davemloft.net> <512B1A54.1030004@cn.fujitsu.com> <20130225.031256.202114640375754800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55951 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758208Ab3BYJDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2013 04:03:43 -0500
In-Reply-To: <20130225.031256.202114640375754800.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/02/25 16:12, David Miller wrote:
> From: Gao feng <gaofeng@cn.fujitsu.com>
> Date: Mon, 25 Feb 2013 16:01:24 +0800
> 
>> I think it's better to make sure netdevice objects have valid pointers
>> by calling list_del in unregister_netdevice_many.
> 
> Please, for the sake of understanding, read the commit below.  And
> please make such necessary research in the future and reference any
> such commits in your proposed patch, as well as explaining why those
> commits in the past were wrong and why you're reverting of them is
> correct.
> 
> Just saying "this isn't necessary" is a very disappointing explanation
> for something as very non-trivial as this is.

Get it, sorry for the noise :(
Will do more research before making patch.

Thanks, the commit below is very useful.

> 
> Thank you.
> 
> commit ceaaec98ad99859ac90ac6863ad0a6cd075d8e0e
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Thu Feb 17 22:59:19 2011 +0000
> 
>     net: deinit automatic LIST_HEAD
>     
>     commit 9b5e383c11b08784 (net: Introduce
>     unregister_netdevice_many()) left an active LIST_HEAD() in
>     rollback_registered(), with possible memory corruption.
>     
>     Even if device is freed without touching its unreg_list (and therefore
>     touching the previous memory location holding LISTE_HEAD(single), better
>     close the bug for good, since its really subtle.
>     
>     (Same fix for default_device_exit_batch() for completeness)
>     
>     Reported-by: Michal Hocko <mhocko@suse.cz>
>     Tested-by: Michal Hocko <mhocko@suse.cz>
>     Reported-by: Eric W. Biderman <ebiderman@xmission.com>
>     Tested-by: Eric W. Biderman <ebiderman@xmission.com>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>     Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>     CC: Ingo Molnar <mingo@elte.hu>
>     CC: Octavian Purdila <opurdila@ixiacom.com>
>     CC: stable <stable@kernel.org> [.33+]
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a18c164..8ae6631 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5066,6 +5066,7 @@ static void rollback_registered(struct net_device *dev)
>  
>  	list_add(&dev->unreg_list, &single);
>  	rollback_registered_many(&single);
> +	list_del(&single);
>  }
>  
>  unsigned long netdev_fix_features(unsigned long features, const char *name)
> @@ -6219,6 +6220,7 @@ static void __net_exit default_device_exit_batch(struct list_head *net_list)
>  		}
>  	}
>  	unregister_netdevice_many(&dev_kill_list);
> +	list_del(&dev_kill_list);
>  	rtnl_unlock();
>  }
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
