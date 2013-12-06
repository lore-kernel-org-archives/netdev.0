From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: properly latch and use autoclose value from sock
 to association
Date: Fri, 6 Dec 2013 11:04:35 -0500
Message-ID: <20131206160435.GB1426@hmsreliant.think-freely.org>
References: <52A0A300.3010409@gmail.com>
 <1386343755-14130-1-git-send-email-nhorman@tuxdriver.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B746B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, Wang Weidong <wangweidong1@huawei.com>,
	David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36130 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814Ab3LFQEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 11:04:40 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B746B@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 06, 2013 at 03:46:31PM -0000, David Laight wrote:
> > From: Neil Horman
> > Currently, sctp associations latch a sockets autoclose value to an association
> > at association init time, subject to capping constraints from the max_autoclose
> > sysctl value.  This leads to an odd situation where an application may set a
> > socket level autoclose timeout, but sliently sctp will limit the autoclose
> > timeout to something less than that.
> > 
> > Fix this by modifying the autoclose setsockopt function to check the limit, cap
> > it and warn the user via syslog that the timeout is capped.  This will allow
> > getsockopt to return valid autoclose timeout values that reflect what subsequent
> > associations actually use.
> ...
> > +	if (sp->autoclose > net->sctp.max_autoclose) {
> > +		pr_warn("Capping autoclose value %d to defined maximum of %lu\n",
> > +			sp->autoclose, net->sctp.max_autoclose);
> > +		sp->autoclose = net->sctp.max_autoclose;
> > +	}
> 
> Is it really reasonable to allow a user to spam syslog this way?
> 
> 	David
> 
Hmm, good point, maybe a pr_ratelimit gate?

Neil

> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
