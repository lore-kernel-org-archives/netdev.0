From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] SCTP: Reduce log spamming for sctp setsockopt
Date: Mon, 16 Dec 2013 10:44:13 -0500
Message-ID: <20131216154413.GD19809@hmsreliant.think-freely.org>
References: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B749A@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39011 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754485Ab3LPPoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 10:44:20 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B749A@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 03:24:48PM -0000, David Laight wrote:
> > From: Neil Horman
> > During a recent discussion regarding some sctp socket options, it was noted that
> > we have several points at which we issue log warnings that can be flooded at an
> > unbounded rate by any user.  Fix this by converting all the pr_warns in the
> > sctp_setsockopt path to be pr_warn_ratelimited.
> > 
> > Note there are several debug level messages as well.  I'm leaving those alone,
> > as, if you turn on pr_debug, you likely want lots of verbosity.
> ...
> > -		pr_warn("Use of struct sctp_assoc_value in delayed_ack socket option deprecated\n");
> > -		pr_warn("Use struct sctp_sack_info instead\n");
> > +		pr_warn_ratelimited("Use of struct sctp_assoc_value in delayed_ack socket option
> > deprecated\n");
> > +		pr_warn_ratelimited("Use struct sctp_sack_info instead\n");
> 
> Do you need to send these as a single ratelimited message?
> 
> 	David
> 
Oh, good point, I'll clean that up.  Thanks!
Neil

> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
