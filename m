From: David Miller <davem@davemloft.net>
Subject: Re: sctp use-uninitialized warning in net-2.6.25
Date: Fri, 18 Jan 2008 15:37:15 -0800 (PST)
Message-ID: <20080118.153715.167557482.davem@davemloft.net>
References: <20080116135957.4eb54958.akpm@linux-foundation.org>
	<20080118.044911.64979691.davem@davemloft.net>
	<4790CDC8.6060000@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58408
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754812AbYARXhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 18:37:14 -0500
In-Reply-To: <4790CDC8.6060000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 18 Jan 2008 11:03:20 -0500

> We can do that, or move the declaration to the only block that uses it.
> Like this:
 ...
> @@ -466,6 +465,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
>  	if (!sctp_verify_init(asoc, chunk->chunk_hdr->type,
>  			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
>  			      &err_chunk)) {
> +		sctp_error_t error;
>  
>  		SCTP_INC_STATS(SCTP_MIB_ABORTEDS);
> 

It's still potentially used uninitialized.

It will only get set if err_chunk is non-zero.

But even if err_chunk is zero, we try to use this
variable.

That's the whole problem, simply moving the variable to
a different scope is not going to fix anything.
