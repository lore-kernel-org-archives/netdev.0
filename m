From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: Re: [PATCH] wcn36xx: Remove unnecessary rcu_read_unlock in
 wcn36xx_bss_info_changed
Date: Tue, 10 Oct 2017 23:54:45 -0700
Message-ID: <20171011065445.GP1165@minitux>
References: <1507467969-24016-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: k.eugene.e@gmail.com, kvalo@codeaurora.org,
        wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507467969-24016-1-git-send-email-baijiaju1990@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun 08 Oct 06:06 PDT 2017, Jia-Ju Bai wrote:

> No rcu_read_lock is called, but rcu_read_unlock is still called.
> Thus rcu_read_unlock should be removed.
> 

Thanks, not sure how I could miss that one. Kalle can you please include
this in a v4.14-rc pull request?


:

Fixes: 39efc7cc7ccf ("wcn36xx: Introduce mutual exclusion of fw configuration")

> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

Acked-by: Bjorn Andersson <bjorn.andersson@linaro.org>

Regards,
Bjorn

> ---
>  drivers/net/wireless/ath/wcn36xx/main.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
> index 35bd50b..b83f01d 100644
> --- a/drivers/net/wireless/ath/wcn36xx/main.c
> +++ b/drivers/net/wireless/ath/wcn36xx/main.c
> @@ -812,7 +812,6 @@ static void wcn36xx_bss_info_changed(struct ieee80211_hw *hw,
>  			if (!sta) {
>  				wcn36xx_err("sta %pM is not found\n",
>  					      bss_conf->bssid);
> -				rcu_read_unlock();
>  				goto out;
>  			}
>  			sta_priv = wcn36xx_sta_to_priv(sta);
> -- 
> 1.7.9.5
> 
> 
> 
> _______________________________________________
> wcn36xx mailing list
> wcn36xx@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/wcn36xx
