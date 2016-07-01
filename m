From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Fix soft lockup for ipv6 network notifier.
Date: Fri, 01 Jul 2016 09:57:27 +0200
Message-ID: <1467359847.11238.34.camel@edumazet-glaptop3.roam.corp.google.com>
References: <57761E04.8030202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: luto@kernel.org, mingo@kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57761E04.8030202@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-07-01 at 15:38 +0800, Ding Tianhong wrote:
...
>  net/ipv6/addrconf.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index f555f4f..e294a3d 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3284,6 +3284,12 @@ restart:
>  		spin_unlock_bh(&addrconf_hash_lock);
>  	}
>  
> +	/*
> +	 * It is safe here to schedule out to avoid softlocking if preempt
> +	 * is disabled.
> +	 */
> +	cond_resched();
> +
>  	write_lock_bh(&idev->lock);
>  
>  	addrconf_del_rs_timer(idev);

Seeing you apparently cooked your patch against an old kernel (which
one ?) ...

I tried vanilla net-next kernel, and apparently I could not trigger the
softlockup you mentioned.

Are you sure current kernel has a bug to begin with ?

Thanks.
