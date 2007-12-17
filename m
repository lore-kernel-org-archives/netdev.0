From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Mon, 17 Dec 2007 14:34:02 -0500
Message-ID: <20071217193402.GD3121@tuxdriver.com>
References: <20071216043148.GE3096@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4992 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936378AbXLQT6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 14:58:33 -0500
Content-Disposition: inline
In-Reply-To: <20071216043148.GE3096@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 15, 2007 at 11:31:48PM -0500, John W. Linville wrote:

> Cyrill Gorcunov (2):
>       ieee80211_rate: missed unlock

>  net/mac80211/ieee80211_rate.c                  |    1 +

> diff --git a/net/mac80211/ieee80211_rate.c b/net/mac80211/ieee80211_rate.c
> index 7254bd6..3260a4a 100644
> --- a/net/mac80211/ieee80211_rate.c
> +++ b/net/mac80211/ieee80211_rate.c
> @@ -33,6 +33,7 @@ int ieee80211_rate_control_register(struct rate_control_ops *ops)
>  		if (!strcmp(alg->ops->name, ops->name)) {
>  			/* don't register an algorithm twice */
>  			WARN_ON(1);
> +			mutex_unlock(&rate_ctrl_mutex);
>  			return -EALREADY;
>  		}
>  	}

Crud...there is a one-line fix in here that should have gone to Dave.

Jeff, (assuming Dave ACKs it) would you mind just taking it your
way along with the other posted patches?  Since this is intended for
2.6.24, there should be no great maintenance hardship if it goes to
Linus through your tree instead of Dave's.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
