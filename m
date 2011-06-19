From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sctp: HEARTBEAT negotiation after ASCONF
Date: Sun, 19 Jun 2011 16:10:34 -0700 (PDT)
Message-ID: <20110619.161034.893667223164209739.davem@davemloft.net>
References: <9C3219F3-AD39-40CF-8422-241D26ECA4D7@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: micchie@sfc.wide.ad.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754765Ab1FSXKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 19:10:42 -0400
In-Reply-To: <9C3219F3-AD39-40CF-8422-241D26ECA4D7@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Thu, 16 Jun 2011 17:56:42 +0900

> @@ -989,6 +991,8 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>  			    ((new_transport->state == SCTP_INACTIVE) ||
>  			     (new_transport->state == SCTP_UNCONFIRMED)))
>  				new_transport = asoc->peer.active_path;
> +			if (new_transport->state == SCTP_UNCONFIRMED) 
> +				continue;
>  
>  			/* Change packets if necessary.  */
>  			if (new_transport != transport) {

This code path uses the asoc->peer.active_path is the new_transport
is in the SCTP_UNCONFIRMED state.  Are you sure your new check is
correct in that case?

Shouldn't you be testing the variable "new_transport" instead?

