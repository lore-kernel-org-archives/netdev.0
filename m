From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Fix sysctl warnings about missing strategy
Date: Wed, 14 Nov 2007 17:33:12 -0800
Message-ID: <20071115013308.GA8449@verge.net.au>
References: <200711131129.58868.borntraeger@de.ibm.com> <20071113.024500.155458534.davem@davemloft.net> <20071114021131.GB2523@verge.net.au> <Pine.LNX.4.58.0711150225280.3658@u.domain.uli> <20071115011431.GA8325@verge.net.au> <m14pfoz4er.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	borntraeger@de.ibm.com, netdev@vger.kernel.org,
	wensong@linux-vs.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:37137 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754170AbXKOBdS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 20:33:18 -0500
Content-Disposition: inline
In-Reply-To: <m14pfoz4er.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 06:25:00PM -0700, Eric W. Biederman wrote:
> Simon Horman <horms@verge.net.au> writes:
> 
> > On Thu, Nov 15, 2007 at 02:38:32AM +0200, Julian Anastasov wrote:
> >
> > Hi Julian,
> >
> >> On Tue, 13 Nov 2007, Simon Horman wrote:
> >
> > [snip]
> >
> >> > As for the commented out entries. They are supposed to be exposed by
> >> > some other means - I believe the thinking was to comply with the don't
> >> > expose stuff in proc any more idea. Where is the best place to expose
> >> > this kind of stuff?
> >> 
> >> 	I assume /proc/sys is still valid place, only sysctl interface
> >> is scheduled for removal.
> >
> > I'm happy to add them there, so long as that is a good place.
> 
> For simple integer values /proc/sys (ala the ascii sysctl interface)
> seems as good as any to me.

Understood.

> The binary interface is problematic because it doesn't get used and
> so we don't show proper discipline with binary integers leading to
> silent ABI changes, and the actual implementation of the handler
> routines get out of sync with the proc side giving us different
> meanings.
> 
> >> So, as long as these entries are not
> >> accessible from sysctl it is safe to run without strategy handler but if
> >> values can be changed then we will need strategy handler to
> >> properly call update_defense_level() as done in proc_do_defense_mode()
> >> as proc_handler. There could be side effects if new mode is not applied.
> >
> > I'm not sure what you are getting at there. I did write a stratergy
> > for update_defense_level(), but I didn't post it, as I thought that
> > it would not be needed if CTL_UNNUMBERED is used.
> 
> Strategy routines are never called if CTL_UNNUMBERED is used.  So you
> should be safe just killing the ctl_name field or setting it
> explicitly to CTL_UNNUMBERED.

Thanks Eric, thats more or less what I thought.

-- 
Horms, California Edition

