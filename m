From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 02/10] net: Add queue state xoff flag for stack
Date: Mon, 28 Nov 2011 17:46:09 +0000
Message-ID: <1322502369.26733.5.camel@bwh-desktop>
References: <alpine.DEB.2.00.1111222139180.14467@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12610 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751795Ab1K1RqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 12:46:12 -0500
In-Reply-To: <alpine.DEB.2.00.1111222139180.14467@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-22 at 21:52 -0800, Tom Herbert wrote:
> Create separate queue state flags so that either the stack or drivers
> can turn on XOFF.  Added a set of functions used in the stack to determine
> if a queue is really stopped (either by stack or driver)
[...]
>  static inline int netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
>  {
> -	return test_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
> +	return test_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
>  }
[...]
> +static inline int netif_xmit_stopped(const struct netdev_queue *dev_queue)
>  {
> -	return dev_queue->state & QUEUE_STATE_XOFF_OR_FROZEN;
> +	return dev_queue->state & QUEUE_STATE_ANY_XOFF;
> +}
[...]

The difference in names here doesn't really suggest the difference in
semantics.  I think they will be easy to confuse.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
