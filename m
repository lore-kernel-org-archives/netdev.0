From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 1/2] bonding: fix incorrect transmit queue offset
Date: Wed, 23 Feb 2011 18:43:36 -0500
Message-ID: <20110223234336.GH11864@gospo.rdu.redhat.com>
References: <1298490169-5224-1-git-send-email-andy@greyhouse.net> <20110223230844.GA16476@linuxace.com> <20110223.151357.245408084.davem@davemloft.net> <1298504269.2211.503.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kernel@linuxace.com,
	andy@greyhouse.net, netdev@vger.kernel.org, fubar@us.ibm.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21115 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751173Ab1BWXoK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 18:44:10 -0500
Content-Disposition: inline
In-Reply-To: <1298504269.2211.503.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 23, 2011 at 11:37:49PM +0000, Ben Hutchings wrote:
> On Wed, 2011-02-23 at 15:13 -0800, David Miller wrote:
> > From: Phil Oester <kernel@linuxace.com>
> > Date: Wed, 23 Feb 2011 15:08:44 -0800
> > 
> > > On Wed, Feb 23, 2011 at 02:42:49PM -0500, Andy Gospodarek wrote:
> > >> + * destination queue.  Using a helper function skips the a call to
> > > 
> > > s/the a/a/ or s/the a/the/
> > > 
> > >> +     while (txq >= dev->real_num_tx_queues) {
> > >> +             /* let the user know if we do not have enough tx queues */
> > >> +             if (net_ratelimit())
> > >> +                     pr_warning("%s selects invalid tx queue %d.  Consider"
> > >> +                                " setting module option tx_queues > %d.",
> > >> +                                dev->name, txq, dev->real_num_tx_queues);
> > >> +             txq -= dev->real_num_tx_queues;
> > >> +     }
> > > 
> > > Think this would be better as a WARN_ONCE, as otherwise syslog will still
> > > get flooded with this - even when ratelimited.  See get_rps_cpu in 
> > > net/core/dev.c as an example.o
> > 
> > Agreed.
> 
> This shouldn't WARN at all.  It is perfectly valid (though non-optimal)
> to have different numbers of queues on two different multiqueue devices.
> 

Agreed.  Plus WARN seemed way to 'loud' for something like this.

