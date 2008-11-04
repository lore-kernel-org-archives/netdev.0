From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Bugme-new] [Bug 11865] New: WOL for E100 Doesn't Work Anymore
Date: Tue, 4 Nov 2008 02:43:32 +0100
Message-ID: <200811040243.33386.rjw@sisk.pl>
References: <bug-11865-10286@http.bugzilla.kernel.org/> <200811040031.46601.rjw@sisk.pl> <F169D4F5E1F1974DBFAFABF47F60C10A0E873FEB@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"jeff@garzik.org" <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"rogerx@sdf.lonestar.org" <rogerx@sdf.lonestar.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:43913 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433AbYKDBiz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 20:38:55 -0500
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A0E873FEB@orsmsx507.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, 4 of November 2008, bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=11865
> 
> ------- Comment #5 from jesse.brandeburg@intel.com  2008-11-03 16:48 -------
> Rafael J. Wysocki wrote:
> >>>> 00:14.0 Ethernet controller: Intel Corporation 82557/8/9 [Ethernet
> >>>> Pro 100] (rev 08) 
> >>>> 
> >>>> Problem Description:
> >>>> As of kernel version 2.6.27, WOL has stopped working.  The box no
> >>>> longer powers on after the magic packet has been sent.  Rebooting
> >>>> using kernel-2.6.26*, WOL *does* work!
> 
> >> I think there is an outstanding patch set to "make device use the
> >> new power management api"
> >> http://marc.info/?l=linux-netdev&m=121874992800468&w=2 
> > 
> > There were three patches like this, one against sky2 and the others
> > for e100 and skge.  The sky2 one has been merged, the other two are
> > in the Jeff's tree AFAICS.
> 
> why did you pick those three drivers?

I could test them myself at that time.

> I'm glad you picked e100 as one of the ones to make the change to, but there
> are a lot of other drivers that support wake on lan, and are probably now
> broken. 

Well, many of them wouldn't work due to the missing ACPI support and the
changes in question were necessary to add that support.  Also, there were
_no_ problem reports related to this until now, except for the sky2 case that
was immediately handled.

> >> It doesn't appear this patch was in 2.6.27, I'm not sure why not,
> >> but I am relatively afraid that lots of devices ability to wake up
> >> got busted in 2.6.27.
> > 
> > Well, unfortunately the maintainers of the networking code were not
> > very interested in these patches, although I had sent them well
> > before 2.6.27 
> > for the first time.
> 
> unless I am mistaken the reason we have drivers in the kernel is that so
> when API changes are made to the kernel the driver is pulled along with
> it.  As I understand it, your changes to the core API should have been
> rejected until the drivers that used power management APIs were updated
> too, otherwise we just get generic user breakage.

Unfortunately, I had to fix some damage that had been caused by someone else
before and I wanted to send fixes for all of the drivers once the first batch
of my patches (sky2, e100, skge, tg3 - I forgot about this one, it's already
in) had been accepted, but that hasn't really happened yet.

> Would you have asked for our help directly (CC:) we probably can/could
> help with our drivers.

Sorry about that, my fault.

> > Generally, the sky2 commit at
> >
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commi
> t;h=9d731d77c9794bb0a264f58d35949a1ab6dcc41c
> > illustrates what needs to be done for other NICs supporting WOL (the
> > key part is to call device_set_wakeup_enable() with appropriate
> > arguments whenever 
> > WOL is enabled/disabled and using for the initialization).
> > 
> > I'm going to do this over time for all of the drivers, but if anyone
> > can help, please do so.
> 
> While that is a worthy goal, I don't think it is okay to have
> regressions until you have time to fix them.  This is a pretty big
> change in a subtly difficult area to both get right and to test.

This isn't really "until I have time to fix them", but "until my fixes are
accepted" thing.  I _really_ care about regressions, but in this case I failed
to make people realize the importance of the patches I was sending.

Moreover, I wasn't quite sure how many systems would _really_ be broken,
because many of them didn't work anyway (despite the support in the drivers),
as I said above.  For this reason, I thought I would fix problems as soon as
they were reported, but there was only one report before this one.

> Your work is appeciated, I just didn't realize it would break all
> devices that didn't implement it.

In fact it doesn't really break them, you can write 'enabled' to
/sys/devices/.../power/wakeup of the device in question and it will work.

> I'm open to corrections to my point of view above.

Well, before those changes WOL didn't work on any of my machines and now
it works on all of them (except for one that hasn't been tested) - with the
already merged patches and the two waiting for merging.

Sorry about the problems caused, I'm willing to fix them ASAP.

Thanks,
Rafael
