From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v5] sctp: be more restrictive in transport selection on
 bundled sacks
Date: Sat, 30 Jun 2012 08:26:47 -0400
Message-ID: <20120630122647.GA22647@neilslaptop.think-freely.org>
References: <1340742704-2192-1-git-send-email-nhorman@tuxdriver.com>
 <1341000929-22933-1-git-send-email-nhorman@tuxdriver.com>
 <20120629.163408.1111786778802302299.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35019 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754249Ab2F3M1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 08:27:00 -0400
Content-Disposition: inline
In-Reply-To: <20120629.163408.1111786778802302299.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 29, 2012 at 04:34:08PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Fri, 29 Jun 2012 16:15:29 -0400
> 
> > +	/* Has this transport moved the ctsn since we last sacked */
> > +	__u32 sack_generation;
> > +
>  ...
> > +		__u32	sack_generation;
> 
> These are __u32 but they only take on the value '1' or '0'.  Please
> use bool and give it a more reasonable name, a name that describes
> how it is really a predicate.
> 
This is wrong.  Its a counter that increments every time we call sctp_make_sack,
so that we can create a unique generation identifier for use in tagging which
transports move ctsn in a given generation.  It saves us from having to iterate
over a list every time we send a sack. 

> > -		struct sctp_association *asoc;
> >  		struct timer_list *timer;
> > -		asoc = pkt->transport->asoc;
> > +		struct sctp_association *asoc = pkt->transport->asoc;
> > +
> 
> Please leave asoc where it was, on the first line.  We encourage
> listing local variables such that the longest lines come first,
> then gradually shorter and short lines.
> 
> > +	/*
> > +	 * Once we have a sack generated, check to see what our sack
> > +	 * generation is, if its 0, reset the transports to 0, and reset
> 
> Please format:
> 
>   /* Like
>    * this.
>    */
> 
> Thanks.
> 
Very well, I'll repost in the next few days
Neil

> 
