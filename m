From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bugme-new] [Bug 9990] New: tg3: eth0: The system may be
 re-ordering memory-mapped I/O cycles
Date: Thu, 14 Feb 2008 16:03:09 -0800
Message-ID: <1203033789.13495.49.camel@dell>
References: <bug-9990-10286@http.bugzilla.kernel.org/>
 <20080214102425.0fc8e3c1.akpm@linux-foundation.org>
 <20080214185627.GK856@gospo.usersys.redhat.com>
 <1203024327.13495.21.camel@dell>
 <20080214221234.GL856@gospo.usersys.redhat.com>
 <1203029289.13495.38.camel@dell>
 <20080214232103.GM856@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org, netdev <netdev@vger.kernel.org>,
	ralf.hildebrandt@charite.de
To: "Andy Gospodarek" <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4077 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758503AbYBOABJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 19:01:09 -0500
In-Reply-To: <20080214232103.GM856@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-02-14 at 18:21 -0500, Andy Gospodarek wrote:
> On Thu, Feb 14, 2008 at 02:48:09PM -0800, Michael Chan wrote:
> > Andy, I think you still missed my point.  I don't believe this problem
> > was caused by the bridge or the chipset at all.  Some corruption caused
> > us to not find the SKB in the TX ring where it was expected.  So the
> > driver assumed it was the bridge re-ordering I/O and printed that
> > warning message and took recovery action.  The recovery action had no
> > effect in this case since apparently it was caused by something else and
> > the corruption happened again later.  This 2nd time, we hit the BUG_ON()
> > seeing that the recovery action did not work.
> > 
> > 
> 
> Ah, I see.  Due to at leat a 2 second delay between the message and the
> panic, I figured it would be good data to gather....
> 
> 
> 
Yeah, 2 seconds for the link to come up after chip reset to recover.  It
then panicked sometime later and rebooted about 90 seconds after the
initial warning message.

It was also running at the slower 100Mbps link speed.  Tx packets stay
longer in the TX ring at this slower speed, increasing the window of
time that the nr_frags in the SKB can be corrupted.

Ralf, please try the debug patch that I sent out earlier.  Thanks.

