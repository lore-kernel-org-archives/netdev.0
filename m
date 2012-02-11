From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [BUG?] bonding, slave selection, carrier loss, etc.
Date: Sat, 11 Feb 2012 18:52:51 +0000
Message-ID: <1328986371.325.7.camel@deadeye>
References: <49CD5B93.7010407@nortel.com>
	 <31087.1238198438@death.nxdomain.ibm.com> <4F35AC78.3010907@genband.com>
	 <28766.1328925233@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <chris.friesen@genband.com>, <andy@greyhouse.net>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7883 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754471Ab2BKSwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2012 13:52:51 -0500
In-Reply-To: <28766.1328925233@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-02-10 at 17:53 -0800, Jay Vosburgh wrote:
> Chris Friesen <chris.friesen@genband.com> wrote:
> 
> >I'm resurrecting an ancient discussion I had with Jay, because I think
> >the issue described below is still present and the code he talked about
> >submitting to close it doesn't appear to have ever gone in.
> 
> 	Yah, I never got it to work quite right; I don't remember
> exactly why.
> 
> >Basically in active/backup mode with mii monitoring there is a window
> >between the active slave device losing carrier and calling
> >netif_carrier_off() and the miimon code actually detecting the loss of
> >the carrier and selecting a new active slave.
> >
> >The best solution would be for bonding to just register for notification
> >of the link going down.  Presumably most drivers should be doing that
> >properly by now, and for devices that get interrupt-driven notification
> >of link status changes this would allow the bonding code to react much
> >quicker.
> 
> 	A quick look at some drivers shows that at least acenic still
> doesn't do netif_carrier_off, so converting entirely to a notifier-based
> failover mechanism would break drivers that work today.
[...]

It might be worth having some sort of feature flag (in priv_flags) that
indicates whether the driver updates the link state.  Alternately,
disable polling of a device once you see a notification.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
