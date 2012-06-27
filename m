From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: be mroe restrictive in transport selection on
 bundled sacks
Date: Tue, 26 Jun 2012 21:05:04 -0700 (PDT)
Message-ID: <20120626.210504.657326352932517334.davem@davemloft.net>
References: <1340742704-2192-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708Ab2F0EFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 00:05:05 -0400
In-Reply-To: <1340742704-2192-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 26 Jun 2012 16:31:44 -0400

> @@ -240,15 +240,20 @@ static sctp_xmit_t sctp_packet_bundle_sack(struct sctp_packet *pkt,
>  	 */
>  	if (sctp_chunk_is_data(chunk) && !pkt->has_sack &&
>  	    !pkt->has_cookie_echo) {
> -		struct sctp_association *asoc;
>  		struct timer_list *timer;
> -		asoc = pkt->transport->asoc;
> +		struct sctp_association *asoc = pkt->transport->asoc;
> +		struct sctp_transport *trans;
> +
>  		timer = &asoc->timers[SCTP_EVENT_TIMEOUT_SACK];
>  
>  		/* If the SACK timer is running, we have a pending SACK */
>  		if (timer_pending(timer)) {
>  			struct sctp_chunk *sack;
>  			asoc->a_rwnd = asoc->rwnd;
> +
> +			if (chunk->transport && !chunk->transport->moved_ctsn)
> +				return retval;
> +
>  			sack = sctp_make_sack(asoc);
>  			if (sack) {
>  				retval = sctp_packet_append_chunk(pkt, sack);

The new local variable 'trans' seems to be unused.
