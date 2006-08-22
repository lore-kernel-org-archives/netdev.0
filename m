From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 03/18] d80211:  pointers as extended booleans
Date: Tue, 22 Aug 2006 02:43:01 -0400
Message-ID: <20060822024301.611aa4de.billfink@mindspring.com>
References: <20060821074107.648561364@sipsolutions.net>
	<20060821075159.171461075@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jkm@devicescape.com,
	linville@tuxdriver.com, jbenc@suse.cz, johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:5846 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net") by vger.kernel.org with ESMTP
	id S1751131AbWHVGnJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 02:43:09 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20060821075159.171461075@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006, Johannes Berg wrote:

> Please review carefully, the task was so boring that I might have made
> stupid mistakes.
> ---
> This huge patch changes d80211 to treat pointers as "extended booleans",
> using "if (!ptr)" and "if (ptr)" instead of comparisons with NULL.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> 
> --- wireless-dev.orig/net/d80211/ieee80211_scan.c	2006-08-20 14:56:09.738192788 +0200
> +++ wireless-dev/net/d80211/ieee80211_scan.c	2006-08-20 14:56:17.398192788 +0200
[...]
> @@ -1105,8 +1105,8 @@ __ieee80211_tx_prepare(struct ieee80211_
>  	tx->fragmented = local->fragmentation_threshold <
>  		IEEE80211_MAX_FRAG_THRESHOLD && tx->u.tx.unicast &&
>  		skb->len + 4 /* FCS */ > local->fragmentation_threshold &&
> -		(local->hw->set_frag_threshold == NULL);
> -	if (tx->sta == NULL)
> +		(!local->hw->set_frag_threshold);
> +	if (!tx->sta)
>  		control->clear_dst_mask = 1;
>  	else if (tx->sta->clear_dst_mask) {
>  		control->clear_dst_mask = 1;
[...]

Just a minor nit.  I don't believe the "()" on the first new line
are needed.

						-Bill
