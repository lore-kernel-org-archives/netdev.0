From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: ieee80211_hw handlers should be allowed to
 sleep
Date: Wed, 18 Oct 2006 15:06:09 +0200
Message-ID: <20061018150609.6542af30@griffin.suse.cz>
References: <200610071123.15561.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jan Kiszka <jan.kiszka@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:14812 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1030268AbWJRNGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 09:06:10 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200610071123.15561.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 7 Oct 2006 11:23:15 +0200, Ivo van Doorn wrote:
> --- a/net/d80211/ieee80211.c
> +++ b/net/d80211/ieee80211.c
> @@ -2075,15 +2075,15 @@ void ieee80211_if_shutdown(struct net_de
>  	case IEEE80211_IF_TYPE_STA:
>  	case IEEE80211_IF_TYPE_IBSS:
>  		sdata->u.sta.state = IEEE80211_DISABLED;
> -		del_timer_sync(&sdata->u.sta.timer);
> +		cancel_delayed_work(&sdata->u.sta.work);
>  		if (local->scan_work.data == sdata->dev) {
>  			local->sta_scanning = 0;
>  			cancel_delayed_work(&local->scan_work);
> -			flush_scheduled_work();
>  			/* see comment in ieee80211_unregister_hw to
>  			 * understand why this works */
>  			local->scan_work.data = NULL;
>  		}
> +		flush_scheduled_work();

This is racy. local->scan_work.data can be set to NULL only after
flush_scheduled_work().

Other than that, the patch looks good to me.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
