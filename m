From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 06/10] mac80211: Add sta_state to ethtool stats.
Date: Thu, 12 Apr 2012 05:49:14 +0200
Message-ID: <1334202554.3788.9.camel@jlt3.sipsolutions.net>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
	 <1334166738-28243-7-git-send-email-greearb@candelatech.com>
	 (sfid-20120411_195329_226978_FB464821)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:57509 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757218Ab2DLDts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 23:49:48 -0400
In-Reply-To: <1334166738-28243-7-git-send-email-greearb@candelatech.com> (sfid-20120411_195329_226978_FB464821)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-11 at 10:52 -0700, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
> 
> Helps to know how the station is doing in it's association
> attempt.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 bbaf564... a63834d... M	net/mac80211/cfg.c
>  net/mac80211/cfg.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
> index bbaf564..a63834d 100644
> --- a/net/mac80211/cfg.c
> +++ b/net/mac80211/cfg.c
> @@ -118,7 +118,7 @@ static const char ieee80211_gstrings_sta_stats[][ETH_GSTRING_LEN] = {
>  	"rx_duplicates", "rx_fragments", "rx_dropped",
>  	"tx_packets", "tx_bytes", "tx_fragments",
>  	"tx_filtered", "tx_retry_failed", "tx_retries",
> -	"beacon_loss", "txrate", "rxrate", "signal",
> +	"beacon_loss", "sta_state", "txrate", "rxrate", "signal",
>  	"channel", "noise", "ch_time", "ch_time_busy",
>  	"ch_time_ext_busy", "ch_time_rx", "ch_time_tx"
>  };
> @@ -534,10 +534,12 @@ static void ieee80211_get_et_stats(struct wiphy *wiphy,
>  		data[i++] += sta->beacon_loss_count;
>  
>  		if (!do_once) {
> -			i += 3;
> +			i += 4;
>  			goto after_once;
>  		}
>  
> +		data[i++] = sta->sta_state;
> +

Gee, I wish it was easier to tell if you were adding it to the right
spot in the list ... any way that could be made easier?

johannes
