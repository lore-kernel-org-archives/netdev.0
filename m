From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 3/5] net-timestamp: ENQ timestamp on
 enqueue to traffic shaping layer
Date: Thu, 31 Jul 2014 13:38:54 -0700 (PDT)
Message-ID: <20140731.133854.1561030580329728471.davem@davemloft.net>
References: <1406735328-7520-1-git-send-email-willemb@google.com>
	<1406735328-7520-4-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbaGaUiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 16:38:55 -0400
In-Reply-To: <1406735328-7520-4-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Wed, 30 Jul 2014 11:48:46 -0400

> Kernel transmit latency is often incurred in the traffic shaping
> layer. This patch adds a new timestamp on transmission just before
> entering traffic shaping. When data travels through multiple devices
> (bonding, tunneling, ...) each device will export an individual
> timestamp.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
 ...
> @@ -247,9 +247,12 @@ enum {
>  	 * all frags to avoid possible bad checksum
>  	 */
>  	SKBTX_SHARED_FRAG = 1 << 5,
> +
> +	/* generate software time stamp when queueing packing in TC */
> +	SKBTX_ENQ_TSTAMP = 1 << 6,

A lot of mixed up terminology being used here.

Subject and commit message say "traffic shaping", yet this comment
says "TC" which I assume means "Traffic Classifier" which isn't
exactly right, the packet scheduler can have no classifiers attached
to it.

Everyone knows what net/sched is, and therefore it might be best to
say "packet scheduler" in all of these places.
