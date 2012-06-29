From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] sctp: be more restrictive in transport selection on
 bundled sacks
Date: Fri, 29 Jun 2012 16:34:08 -0700 (PDT)
Message-ID: <20120629.163408.1111786778802302299.davem@davemloft.net>
References: <1340742704-2192-1-git-send-email-nhorman@tuxdriver.com>
	<1341000929-22933-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39010 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755175Ab2F2XeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 19:34:10 -0400
In-Reply-To: <1341000929-22933-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 29 Jun 2012 16:15:29 -0400

> +	/* Has this transport moved the ctsn since we last sacked */
> +	__u32 sack_generation;
> +
 ...
> +		__u32	sack_generation;

These are __u32 but they only take on the value '1' or '0'.  Please
use bool and give it a more reasonable name, a name that describes
how it is really a predicate.

> -		struct sctp_association *asoc;
>  		struct timer_list *timer;
> -		asoc = pkt->transport->asoc;
> +		struct sctp_association *asoc = pkt->transport->asoc;
> +

Please leave asoc where it was, on the first line.  We encourage
listing local variables such that the longest lines come first,
then gradually shorter and short lines.

> +	/*
> +	 * Once we have a sack generated, check to see what our sack
> +	 * generation is, if its 0, reset the transports to 0, and reset

Please format:

  /* Like
   * this.
   */

Thanks.
