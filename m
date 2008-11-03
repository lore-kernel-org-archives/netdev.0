From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Bugme-new] [Bug 11865] New: WOL for E100 Doesn't Work Anymore
Date: Tue, 4 Nov 2008 00:31:45 +0100
Message-ID: <200811040031.46601.rjw@sisk.pl>
References: <bug-11865-10286@http.bugzilla.kernel.org/> <20081027220224.6333b675.akpm@linux-foundation.org> <F169D4F5E1F1974DBFAFABF47F60C10A0E873C3C@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"rogerx@sdf.lonestar.org" <rogerx@sdf.lonestar.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:43468 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752346AbYKCX1V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 18:27:21 -0500
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A0E873C3C@orsmsx507.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 3 of November 2008, Brandeburg, Jesse wrote:
> Andrew Morton wrote:
> > (switched to email.  Please respond via emailed reply-to-all, not via
> > the bugzilla web interface).
> > 
> > On Sun, 26 Oct 2008 21:56:35 -0700 (PDT)
> > bugme-daemon@bugzilla.kernel.org wrote: 
> > 
> >> http://bugzilla.kernel.org/show_bug.cgi?id=11865
> >> 
> >>            Summary: WOL for E100 Doesn't Work Anymore           
> >>            Product: Drivers Version: 2.5
> >>      KernelVersion: 2.6.27
> >>           Platform: All
> >>         OS/Version: Linux
> >>               Tree: Mainline
> >>             Status: NEW
> >>           Severity: normal
> >>           Priority: P1
> >>          Component: Network
> >>         AssignedTo: jgarzik@pobox.com
> >>         ReportedBy: rogerx@sdf.lonestar.org
> >> 
> >> 
> >> Latest working kernel version: 2.6.27
> > 
> > This should read 2.6.26.  It is a regression.
> > 
> >> Earliest failing kernel version: 2.6.27
> >> Distribution: Gentoo
> >> Hardware Environment: 2x750P3 1G RAM w/
> >> 
> >> 00:14.0 Ethernet controller: Intel Corporation 82557/8/9 [Ethernet
> >> Pro 100] (rev 08) 
> >> 
> >> Problem Description:
> >> As of kernel version 2.6.27, WOL has stopped working.  The box no
> >> longer powers on after the magic packet has been sent.  Rebooting
> >> using kernel-2.6.26*, WOL *does* work! 
> 
> what does cat /proc/acpi/wakeup say?  (if you have legacy acpi procfs)
> 
> >> 
> >> Steps to reproduce:
> >> (Not needed.  Self Explanatory.)
> >> 
> >> 
> >> I noticed 3 lines of code in e100.c added/modified since 2.6.26*,
> >> however, I reversed 2 lines of code to 2.6.26 and the other line was
> >> just added an additional pointer, for which I left alone. 
> >> Recompiled, rebooted and WOL still didn't work using 2.6.27.  I'm
> >> guessing, the source of this bug lies elsewhere. 
> 
> I think there is an outstanding patch set to "make device use the new
> power management api"
> http://marc.info/?l=linux-netdev&m=121874992800468&w=2

There were three patches like this, one against sky2 and the others for e100
and skge.  The sky2 one has been merged, the other two are in the Jeff's tree
AFAICS.

> It doesn't appear this patch was in 2.6.27, I'm not sure why not, but I
> am relatively afraid that lots of devices ability to wake up got busted
> in 2.6.27.

Well, unfortunately the maintainers of the networking code were not very
interested in these patches, although I had sent them well before 2.6.27
for the first time.

Generally, the sky2 commit at
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=9d731d77c9794bb0a264f58d35949a1ab6dcc41c
illustrates what needs to be done for other NICs supporting WOL (the key part
is to call device_set_wakeup_enable() with appropriate arguments whenever
WOL is enabled/disabled and using for the initialization).

I'm going to do this over time for all of the drivers, but if anyone can help,
please do so.

Thanks,
Rafael
