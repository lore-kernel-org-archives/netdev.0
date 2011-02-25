From: Phil Oester <kernel@linuxace.com>
Subject: Re: [PATCH 1/2] bonding: fix incorrect transmit queue offset
Date: Fri, 25 Feb 2011 14:56:36 -0800
Message-ID: <20110225225636.GA18792@linuxace.com>
References: <20110223230844.GA16476@linuxace.com>
 <20110223.151357.245408084.davem@davemloft.net>
 <1298504269.2211.503.camel@localhost>
 <20110223.155451.70202591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, andy@greyhouse.net,
	netdev@vger.kernel.org, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42900 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932539Ab1BYW4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 17:56:42 -0500
Received: by gyh20 with SMTP id 20so895021gyh.19
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 14:56:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110223.155451.70202591.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 23, 2011 at 03:54:51PM -0800, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 23 Feb 2011 23:37:49 +0000
> 
> > On Wed, 2011-02-23 at 15:13 -0800, David Miller wrote:
> >> From: Phil Oester <kernel@linuxace.com>
> >> Date: Wed, 23 Feb 2011 15:08:44 -0800
> >> 
> >> > On Wed, Feb 23, 2011 at 02:42:49PM -0500, Andy Gospodarek wrote:
> >> >> +     while (txq >= dev->real_num_tx_queues) {
> >> >> +             /* let the user know if we do not have enough tx queues */
> >> >> +             if (net_ratelimit())
> >> >> +                     pr_warning("%s selects invalid tx queue %d.  Consider"
> >> >> +                                " setting module option tx_queues > %d.",
> >> >> +                                dev->name, txq, dev->real_num_tx_queues);
> >> >> +             txq -= dev->real_num_tx_queues;
> >> >> +     }
> >> > 
> >> > Think this would be better as a WARN_ONCE, as otherwise syslog will still
> >> > get flooded with this - even when ratelimited.  See get_rps_cpu in 
> >> > net/core/dev.c as an example.o
> >> 
> >> Agreed.
> > 
> > This shouldn't WARN at all.  It is perfectly valid (though non-optimal)
> > to have different numbers of queues on two different multiqueue devices.
> 
> That's also a good point.

The patch works as expected.  Do we have any agreement on a final version?

Phil
