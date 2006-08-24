From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 1/4] Try 2: Add wireless statistics to d80211
Date: Thu, 24 Aug 2006 13:59:34 +0200
Message-ID: <20060824135934.4df0b1ba@griffin.suse.cz>
References: <44ED16AB.2080306@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:18389 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751171AbWHXL7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 07:59:36 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44ED16AB.2080306@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Aug 2006 22:02:03 -0500, Larry Finger wrote:
> This patch modifies d80211 to add wireless statistics.
> 
> Signed-Off-By: Larry Finger@lwfinger.net>

Please fix the Signed-off-by line.

> 
> ======================================
> diff --git a/include/net/d80211.h b/include/net/d80211.h
> index 42fdbf7..70655dc 100644
> --- a/include/net/d80211.h
> +++ b/include/net/d80211.h
> @@ -205,6 +205,8 @@ struct ieee80211_rx_status {
>           int channel;
>           int phymode;
>           int ssi;
> +	int signal;
> +	int noise;
>           int antenna;
>           int rate;
>           int flag;
> @@ -499,6 +501,9 @@ struct ieee80211_hw {
>           /* This is the time in us to change channels
>            */
>           int channel_change_time;
> +	/* This is maximum value of rssi reported by this interface
> +	 */
> +	int maxssi;

Device, not interface. And please do not put */ to a new line.

> [...]
> --- a/net/d80211/ieee80211_ioctl.c
> +++ b/net/d80211/ieee80211_ioctl.c
> [...]
> @@ -3019,7 +3062,6 @@ static int ieee80211_ioctl_giwauth(struc
>   	return ret;
>   }
> 
> -
>   static int ieee80211_ioctl_siwencodeext(struct net_device *dev,
>   					struct iw_request_info *info,
>   					struct iw_point *erq, char *extra)

Please do not touch parts outside of the code you are
fixing/improving/etc. We'll need a code style patch later, but not now -
there are still too many patches floating around and I don't want to
break them more than is necessary.

Other then that, it looks good.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
