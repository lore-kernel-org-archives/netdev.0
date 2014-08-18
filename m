From: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH] carl9170: Replace rcu_dereference() with rcu_access_pointer()
Date: Mon, 18 Aug 2014 21:29:36 +0200
Message-ID: <3029076.uaUkTd8nru@debian64>
References: <20140817104806.GA14533@ada>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: Andreea-Cristina Bernat <bernat.ada-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140817104806.GA14533@ada>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday, August 17, 2014 01:48:07 PM Andreea-Cristina Bernat wrote:
> The rcu_dereference() call is used directly in a condition.
> Since its return value is never dereferenced it is recommended to use
> "rcu_access_pointer()" instead of "rcu_dereference()".
> Therefore, this patch makes the replacement.
> [...]
> Signed-off-by: Andreea-Cristina Bernat <bernat.ada-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/wireless/ath/carl9170/main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
> index f8ded84..12018ff 100644
> --- a/drivers/net/wireless/ath/carl9170/main.c
> +++ b/drivers/net/wireless/ath/carl9170/main.c
> @@ -1431,7 +1431,7 @@ static int carl9170_op_ampdu_action(struct ieee80211_hw *hw,
>  			return -EOPNOTSUPP;
>  
>  		rcu_read_lock();
> -		if (rcu_dereference(sta_info->agg[tid])) {
> +		if (rcu_access_pointer(sta_info->agg[tid])) {
>  			rcu_read_unlock();
>  			return -EBUSY;
>  		}

There's more. The check does not do a whole lot. I think *it* [the check] and the
rcu_read_[un]lock [and the return -EBUSY] can be removed completely from the
IEEE80211_AMPDU_TX_START code-path in carl9170_op_ampdu_action.

It would be awesome, if you could you make a patch which removes this 
unneeded cosmic-ray-protection check :-) .

Thanks
Christian
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
