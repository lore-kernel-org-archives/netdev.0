From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] napi: use non-interruptible sleep in napi_disable
Date: Thu, 25 Oct 2007 01:10:32 -0400
Message-ID: <47202548.6040100@garzik.org>
References: <20071025035920.C2D39DDECE@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41819 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753009AbXJYFKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 01:10:34 -0400
In-Reply-To: <20071025035920.C2D39DDECE@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
> The current napi_disable() uses msleep_interruptible() but doesn't
> (and can't) exit in case there's a signal, thus ending up doing a
> hot spin without a cpu_relax. Use uninterruptible sleep instead.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> 
>  include/linux/netdevice.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-work/include/linux/netdevice.h
> ===================================================================
> --- linux-work.orig/include/linux/netdevice.h	2007-10-17 12:39:16.000000000 +1000
> +++ linux-work/include/linux/netdevice.h	2007-10-17 12:45:00.000000000 +1000
> @@ -390,7 +390,7 @@ static inline void napi_complete(struct 
>  static inline void napi_disable(struct napi_struct *n)
>  {
>  	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
> -		msleep_interruptible(1);
> +		msleep(1);
>  }

ACK


