From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bugme-new] [Bug 9990] New: tg3: eth0: The system may be re-ordering memory-mapped I/O cycles
Date: Thu, 14 Feb 2008 18:21:03 -0500
Message-ID: <20080214232103.GM856@gospo.usersys.redhat.com>
References: <bug-9990-10286@http.bugzilla.kernel.org/> <20080214102425.0fc8e3c1.akpm@linux-foundation.org> <20080214185627.GK856@gospo.usersys.redhat.com> <1203024327.13495.21.camel@dell> <20080214221234.GL856@gospo.usersys.redhat.com> <1203029289.13495.38.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org, netdev <netdev@vger.kernel.org>,
	ralf.hildebrandt@charite.de
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47126 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757372AbYBNXVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 18:21:45 -0500
Content-Disposition: inline
In-Reply-To: <1203029289.13495.38.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 14, 2008 at 02:48:09PM -0800, Michael Chan wrote:
> On Thu, 2008-02-14 at 17:12 -0500, Andy Gospodarek wrote:
> > On Thu, Feb 14, 2008 at 01:25:27PM -0800, Michael Chan wrote:
> > > On Thu, 2008-02-14 at 13:56 -0500, Andy Gospodarek wrote:
> > > > That should be a simple matter of adding the right pci-ids to
> > > > tg3_get_invariants -- hopefully Ralf will respond and we can get that
> > > > knocked out quickly.
> > > > 
> > > > 
> > > 
> > > It doesn't look like it was re-ordered IO.  If it was, it should have
> > > self-recovered without hitting the BUG().
> > > 
> > 
> > Good catch, Michael!  I missed that it paniced since I expect to see
> > some sort of backtrace when that happens.  We should try and get that
> > bridge added to the list though, to avoid repeated complaints that there
> > is a tg3 bug.
> > 
> > 
> 
> Andy, I think you still missed my point.  I don't believe this problem
> was caused by the bridge or the chipset at all.  Some corruption caused
> us to not find the SKB in the TX ring where it was expected.  So the
> driver assumed it was the bridge re-ordering I/O and printed that
> warning message and took recovery action.  The recovery action had no
> effect in this case since apparently it was caused by something else and
> the corruption happened again later.  This 2nd time, we hit the BUG_ON()
> seeing that the recovery action did not work.
> 
> 

Ah, I see.  Due to at leat a 2 second delay between the message and the
panic, I figured it would be good data to gather....


