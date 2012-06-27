From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: be mroe restrictive in transport selection on
 bundled sacks
Date: Wed, 27 Jun 2012 06:24:19 -0400
Message-ID: <20120627102419.GA19313@hmsreliant.think-freely.org>
References: <1340742704-2192-1-git-send-email-nhorman@tuxdriver.com>
 <20120626.210504.657326352932517334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53187 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756723Ab2F0KYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 06:24:32 -0400
Content-Disposition: inline
In-Reply-To: <20120626.210504.657326352932517334.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 26, 2012 at 09:05:04PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 26 Jun 2012 16:31:44 -0400
> 
> > @@ -240,15 +240,20 @@ static sctp_xmit_t sctp_packet_bundle_sack(struct sctp_packet *pkt,
> >  	 */
> >  	if (sctp_chunk_is_data(chunk) && !pkt->has_sack &&
> >  	    !pkt->has_cookie_echo) {
> > -		struct sctp_association *asoc;
> >  		struct timer_list *timer;
> > -		asoc = pkt->transport->asoc;
> > +		struct sctp_association *asoc = pkt->transport->asoc;
> > +		struct sctp_transport *trans;
> > +
> >  		timer = &asoc->timers[SCTP_EVENT_TIMEOUT_SACK];
> >  
> >  		/* If the SACK timer is running, we have a pending SACK */
> >  		if (timer_pending(timer)) {
> >  			struct sctp_chunk *sack;
> >  			asoc->a_rwnd = asoc->rwnd;
> > +
> > +			if (chunk->transport && !chunk->transport->moved_ctsn)
> > +				return retval;
> > +
> >  			sack = sctp_make_sack(asoc);
> >  			if (sack) {
> >  				retval = sctp_packet_append_chunk(pkt, sack);
> 
> The new local variable 'trans' seems to be unused.
> 
Crap, thank you Dave, that was a holdover from an initial pass I had made in
writing this.  I'll repost with that removed once Vald has a chance to look this
over
Neil
