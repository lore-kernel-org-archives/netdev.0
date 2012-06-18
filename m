From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] [XFRM] Fix unexpected SA hard expiration after
 changing date
Date: Mon, 18 Jun 2012 13:05:23 +0200
Message-ID: <20120618110523.GA29295@secunet.com>
References: <1340007856-27651-1-git-send-email-fan.du@windriver.com>
 <1340007856-27651-2-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org, fdu@windriver.com
To: "fan.du" <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47230 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750786Ab2FRLFh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2012 07:05:37 -0400
Content-Disposition: inline
In-Reply-To: <1340007856-27651-2-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 18, 2012 at 04:24:16PM +0800, fan.du wrote:
> After SA is setup, one timer is armed to detect soft/hard expiration,
> however the timer handler uses xtime to do the math. This makes hard
> expiration occurs first before soft expiration after setting new date
> with big interval. As a result new child SA is deleted before rekeying
> the new one.
> 
> Signed-off-by: fan.du <fan.du@windriver.com>
> ---
>  include/net/xfrm.h    |    2 ++
>  net/xfrm/xfrm_state.c |   22 ++++++++++++++++++----
>  2 files changed, 20 insertions(+), 4 deletions(-)
> 
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index 2933d74..1734acc 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -214,6 +214,8 @@ struct xfrm_state
>  	/* Private data of this transformer, format is opaque,
>  	 * interpreted by xfrm_type methods. */
>  	void			*data;
> +	u32				flags;

We already have the xflags field, it holds exactly one flag
at the moment. So I think we don't need yet another u32 that
holds one flag too.
