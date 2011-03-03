From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: bonding...
Date: Thu, 3 Mar 2011 15:59:02 -0500
Message-ID: <20110303205902.GP11864@gospo.rdu.redhat.com>
References: <20110302.214910.112578818.davem@davemloft.net> <20110303114539.GB5146@hmsreliant.think-freely.org> <20110303160404.GO11864@gospo.rdu.redhat.com> <6286.1299173065@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58386 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932281Ab1CCU7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 15:59:13 -0500
Content-Disposition: inline
In-Reply-To: <6286.1299173065@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 03, 2011 at 09:24:25AM -0800, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> >
> >I would be willing to do it, but my one of my goals would be to prevent
> >some of the feature creep we are currently seeing with bonding (as Ben
> >has suggested).  That doesn't mean I want to stop all new features, but
> >at this point things are starting to get out of control. I suspect this
> >is why Jay has struggled to keep up with the patches.
> 
> 	My main problem keeping up at the moment is another demand on my
> time that should run its course in a couple of weeks.  My time for
> community activity is somewhat limited until then.
> 
> 	As far as the features go, yes, I agree that things are getting
> out of hand.  The two pending patches for special cases related to
> 802.3ad (Oleg's patch to permit round robining, the other to enable
> spanning aggregators across switches), for example, are fine
> functionality, but there really needs to be a better, generic, way to do
> this sort of niche case activity without adding more knobs.
> 
> 	I personally like Stephen's suggestion to hook bonding into a
> netfilter gadget, similar to ebtables for bridge.  Done properly, such a
> gadget should handle (or be extended to handle) the niche cases that
> right now end up as new knobs in the driver.
> 
> >I would also want to look at a restructuring of the configuration.  The
> >lines are starting to blur between some of the modes and output port
> >selection for other modes and that needs to be cleared up.
> 
> 	What did you have in mind here?
> 

This is what I've been thinking about for a while, but it's basically
off the top of my head.  Of couse it seems reasonable to me....

As more people try to add functionality that exists in one mode to
another mode it becomes clear that the distinction between some of the
modes isn't clear anymore.  If we really want round-robin send on
802.3ad and xor modes, why do we have rr and xor anymore?  For that
matter, why not just get rid of active-backup too and add an option for
transmit algorithm to be active-backup.  It can get to be a slippery
slope when you start to combine them as it seems like you would just be
changing the language from 'mode' to 'transmit algoritm,' but I still
think it is worth thinking about.

Instead of thinking about the 7 modes of bonding that currently exist,
it makes more sense to me to think of the bond as being dynamic or
static (with 802.3ad being the only mode that is currently dynamic) and
then the user can select the transmit algorithm.  Obviously this isn't
totally flushed out since some transmit algorithms will be able to
support arp monitoring and some will not, but I suspect you know where
I'm going.

