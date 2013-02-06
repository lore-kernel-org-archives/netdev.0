From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: [PATCH] net: mac80211/cfg.c: fix error using of sizeof()
Date: Wed, 06 Feb 2013 09:58:18 -0800
Message-ID: <511299BA.905@candelatech.com>
References: <1360167826-29265-1-git-send-email-dinggnu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Cong Ding <dinggnu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1360167826-29265-1-git-send-email-dinggnu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/06/2013 08:23 AM, Cong Ding wrote:
> Using 'sizeof' on array given as function argument returns size of a pointer
> rather than the size of array.
>
> Signed-off-by: Cong Ding <dinggnu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>   net/mac80211/cfg.c |    3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
> index 661b878..af561d5 100644
> --- a/net/mac80211/cfg.c
> +++ b/net/mac80211/cfg.c
> @@ -2058,7 +2058,8 @@ static int ieee80211_set_mcast_rate(struct wiphy *wiphy, struct net_device *dev,
>   {
>   	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
>
> -	memcpy(sdata->vif.bss_conf.mcast_rate, rate, sizeof(rate));
> +	memcpy(sdata->vif.bss_conf.mcast_rate, rate,
> +			sizeof(int) * IEEE80211_NUM_BANDS);

Should it perhaps be:  sizeof(*rate) * IEEE80211_NUM_BANDS
just in case the type ever changes?

Thanks,
Ben

>
>   	return 0;
>   }
>


-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
