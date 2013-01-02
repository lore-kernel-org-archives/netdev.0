From: Sujith Manoharan <sujith-TPRpbcbO+rZAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH] ath9k_htc: Fix skb leaks
Date: Wed, 2 Jan 2013 10:00:19 +0530
Message-ID: <20707.47067.474241.813195@gargle.gargle.HOWL>
References: <1357098567-8558-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Vasanthakumar Thiagarajan <vthiagar-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Senthil Balasubramanian <senthilb-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1357098567-8558-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Larry Finger wrote:
> diff --git a/drivers/net/wireless/ath/ath9k/htc_hst.c b/drivers/net/wireless/ath/ath9k/htc_hst.c
> index 4a9570d..a304748 100644
> --- a/drivers/net/wireless/ath/ath9k/htc_hst.c
> +++ b/drivers/net/wireless/ath/ath9k/htc_hst.c
> @@ -278,10 +278,12 @@ int htc_connect_service(struct htc_target *target,
>  	if (!time_left) {
>  		dev_err(target->dev, "Service connection timeout for: %d\n",
>  			service_connreq->service_id);
> -		return -ETIMEDOUT;
> +		ret = -ETIMEDOUT;
> +		goto err;
>  	}
>  
>  	*conn_rsp_epid = target->conn_rsp_epid;
> +	kfree_skb(skb);
>  	return 0;
>  err:
>  	kfree_skb(skb);

The allocated skb should be freed in the TX completion hander,
ath9k_htc_txcompletion_cb() - doing it in htc_connect_service() is wrong, I think.

Sujith
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
