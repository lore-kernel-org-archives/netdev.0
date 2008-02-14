From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bugme-new] [Bug 9990] New: tg3: eth0: The system may be
 re-ordering memory-mapped I/O cycles
Date: Thu, 14 Feb 2008 14:48:09 -0800
Message-ID: <1203029289.13495.38.camel@dell>
References: <bug-9990-10286@http.bugzilla.kernel.org/>
 <20080214102425.0fc8e3c1.akpm@linux-foundation.org>
 <20080214185627.GK856@gospo.usersys.redhat.com>
 <1203024327.13495.21.camel@dell>
 <20080214221234.GL856@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org, netdev <netdev@vger.kernel.org>,
	ralf.hildebrandt@charite.de
To: "Andy Gospodarek" <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4553 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757550AbYBNWqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 17:46:13 -0500
In-Reply-To: <20080214221234.GL856@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-02-14 at 17:12 -0500, Andy Gospodarek wrote:
> On Thu, Feb 14, 2008 at 01:25:27PM -0800, Michael Chan wrote:
> > On Thu, 2008-02-14 at 13:56 -0500, Andy Gospodarek wrote:
> > > That should be a simple matter of adding the right pci-ids to
> > > tg3_get_invariants -- hopefully Ralf will respond and we can get that
> > > knocked out quickly.
> > > 
> > > 
> > 
> > It doesn't look like it was re-ordered IO.  If it was, it should have
> > self-recovered without hitting the BUG().
> > 
> 
> Good catch, Michael!  I missed that it paniced since I expect to see
> some sort of backtrace when that happens.  We should try and get that
> bridge added to the list though, to avoid repeated complaints that there
> is a tg3 bug.
> 
> 

Andy, I think you still missed my point.  I don't believe this problem
was caused by the bridge or the chipset at all.  Some corruption caused
us to not find the SKB in the TX ring where it was expected.  So the
driver assumed it was the bridge re-ordering I/O and printed that
warning message and took recovery action.  The recovery action had no
effect in this case since apparently it was caused by something else and
the corruption happened again later.  This 2nd time, we hit the BUG_ON()
seeing that the recovery action did not work.


