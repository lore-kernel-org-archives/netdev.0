From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [XFRM] Fix unexpected SA hard expiration after
 changing date
Date: Mon, 25 Jun 2012 15:29:27 -0700 (PDT)
Message-ID: <20120625.152927.1898837361946168264.davem@davemloft.net>
References: <1340259961-30354-1-git-send-email-fdu@windriver.com>
	<1340259961-30354-2-git-send-email-fdu@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: fdu@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56199 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757545Ab2FYW32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 18:29:28 -0400
In-Reply-To: <1340259961-30354-2-git-send-email-fdu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fdu@windriver.com>
Date: Thu, 21 Jun 2012 14:26:01 +0800

> After SA is setup, one timer is armed to detect soft/hard expiration,
> however the timer handler uses xtime to do the math. This makes hard
> expiration occurs first before soft expiration after setting new date
> with big interval. As a result new child SA is deleted before rekeying
> the new one.
> 
> Signed-off-by: Fan Du <fdu@windriver.com>
> ---
>  include/net/xfrm.h    |  3 +++
>  net/xfrm/xfrm_state.c | 21 +++++++++++++++++----
>  2 files changed, 20 insertions(+), 4 deletions(-)
> 
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index 2933d74..8d16777 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -197,6 +197,8 @@ struct xfrm_state
>  
>  	struct xfrm_lifetime_cur curlft;
>  	struct timer_list	timer;
> +	/* used to fix curlft->add_time when changing date */
> +	long		saved_tmo;

'saved_tmo' is not properly indented to line up with the
struct member names above it.
