From: Greg KH <gregkh@suse.de>
Subject: Re: [Bugme-new] [Bug 16257] New: sysfs changes break hwsim and
 bnep drivers
Date: Mon, 21 Jun 2010 20:56:31 -0700
Message-ID: <20100622035631.GA3755@suse.de>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
 <20100621150826.762ac9f2.akpm@linux-foundation.org>
 <m1mxuodo0n.fsf@fess.ebiederm.org>
 <20100621222938.GA20583@suse.de>
 <m1eig0dmhk.fsf@fess.ebiederm.org>
 <20100621231058.GA1066@suse.de>
 <m14ogwc4ou.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38030 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758690Ab0FVD6g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 23:58:36 -0400
Content-Disposition: inline
In-Reply-To: <m14ogwc4ou.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 21, 2010 at 05:05:21PM -0700, Eric W. Biederman wrote:
> Greg KH <gregkh@suse.de> writes:
> 
> > On Mon, Jun 21, 2010 at 03:55:35PM -0700, Eric W. Biederman wrote:
> >> Greg KH <gregkh@suse.de> writes:
> >> 
> >> > I _really_ do not like this patch.
> >> >
> >> > The correct thing is to fix the modules that are affected, and that's
> >> > only the wireless testing module, right?  Or is there something else?
> >> >
> >> > And if that code is properly converted to a bus, what needs to change in
> >> > the driver core?
> >> 
> >> The usb bnep driver.
> >
> > Odd, what is bnep doing differently here from all other network drivers?
> > Is it trying to stack the bluetooth class in the middle somehow?
> > Shouldn't this be easy to fix up in the driver itself?
> 
> The cause of all of the failures is a class device with a class device
> parent, instead of a bus device parent.  Which causes the net/ directory 
> not to be created for us to put the network devices under.
> 
> I don't have a clue about how that driver works, and I don't know how many
> other drivers that do something strange like this are out there lurking.
> 
> I have not been involved previously in any changes from class device to
> bus device so I don't have a clue how difficult it would.  All I know
> is that with the mac80211_hwsim driver we had first had two people who
> really knew what they were doing and it was hard enough there still
> isn't a working conversion away from class devices.

But what caused the breakage here?

Does this only show up if you enable network namespaces?  Or is it a
problem with the "normal" kernel configuration of no network namespaces?

The only thing that changed here was your network namespace work, what
caused this problem to show up?  Was it bisectable down to a single
patch?

Classes on top of classes should never have originally worked, I guess
we just let them slide by accident, and we can go and fix them up as
they are found.  But for now, for .35, it would be good to find the root
cause of the problem here.  It might be as simple as putting a
CONFIG_BROKEN on network namespaces until we get this working, right?

thanks,

greg k-h
