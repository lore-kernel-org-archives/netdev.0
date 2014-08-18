From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH] mac80211: disable CSA client with channel contexts for
 all drivers
Date: Mon, 18 Aug 2014 12:01:42 +0300
Message-ID: <1408352502.29649.10.camel@dubbel>
References: <1408352303-8354-1-git-send-email-luca@coelho.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, michal.kazior@tieto.com,
	torvalds@linux-foundation.org, emmanuel.grumbach@intel.com,
	linux-wireless@vger.kernel.org, ilw@linux.intel.com,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dedo.coelho.fi ([88.198.205.34]:41542 "EHLO dedo.coelho.fi"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750906AbaHRJCR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2014 05:02:17 -0400
In-Reply-To: <1408352303-8354-1-git-send-email-luca@coelho.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

I sent this directly to you because everyone (but me :P) is traveling
and it's intended for the current wireless tree.  This should solve the
OOPS that Linus has experienced with the CSA client code.

--
Cheers,
Luca.


On Mon, 2014-08-18 at 11:58 +0300, Luca Coelho wrote:
> From: Luciano Coelho <luciano.coelho@intel.com>
> 
> The channel switch announcement code has some serious problems at the
> moment.  Disable it for all drivers until it has been tested and
> finalized properly.
> 
> Signed-off-by: Luciano Coelho <luciano.coelho@intel.com>
> ---
>  net/mac80211/main.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/net/mac80211/main.c b/net/mac80211/main.c
> index e0ab432..4b8eee8 100644
> --- a/net/mac80211/main.c
> +++ b/net/mac80211/main.c
> @@ -758,6 +758,12 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
>  	netdev_features_t feature_whitelist;
>  	struct cfg80211_chan_def dflt_chandef = {};
>  
> +	/* The CSA client code is not very stable yet and seems to be
> +	 * causing trouble.  Disable it for all drivers until
> +	 * everything has been fixed and tested properly.
> +	 */
> +	hw->flags &= ~IEEE80211_HW_CHANCTX_STA_CSA;
> +
>  	if (hw->flags & IEEE80211_HW_QUEUE_CONTROL &&
>  	    (local->hw.offchannel_tx_hw_queue == IEEE80211_INVAL_HW_QUEUE ||
>  	     local->hw.offchannel_tx_hw_queue >= local->hw.queues))
