From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] e1000e: test MSI interrupts
Date: Thu, 27 Mar 2008 18:33:37 -0400
Message-ID: <20080327223337.GP856@gospo.usersys.redhat.com>
References: <20080326183631.25114.90265.stgit@localhost.localdomain> <47EA9911.8040101@garzik.org> <47EAB54A.1060306@intel.com> <36D9DB17C6DE9E40B059440DB8D95F5204BF07F7@orsmsx418.amr.corp.intel.com> <20080327220527.GO856@gospo.usersys.redhat.com> <47EC1CC9.5080305@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Jeff Garzik <jeff@garzik.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51841 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100AbYC0Wd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 18:33:58 -0400
Content-Disposition: inline
In-Reply-To: <47EC1CC9.5080305@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2008 at 03:16:41PM -0700, Kok, Auke wrote:
> Andy Gospodarek wrote:
> > On Thu, Mar 27, 2008 at 10:53:43AM -0700, Brandeburg, Jesse wrote:
> >> Kok, Auke wrote:
> >>> Jeff Garzik wrote:
> >>>> Auke Kok wrote:
> >>>>> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >>>>>
> >>>>> Test the MSI interrupt physically once before assuming that it
> >>>>> actually works. Several platforms have already come across that
> >>>>> have non-functional MSI interrupts and this code will attempt
> >>>>> to detect those safely. Once the test succeeds MSI interrupts
> >>>>> will be enabled.
> >>>>>
> >>>>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >>>>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> >>>> Ah, the perennial add-same-test-to-every-driver conundrum.
> >>>>
> >>>> I think we are far enough along with MSI to _not_ do this anymore in
> >>>> drivers. 
> >> Actually, I'm hoping you'll allow this Jeff, we have a production system
> >> (see below) we know about that doesn't like the way 82571 formats MSI
> >> interrupt messages.  All other systems seem to be okay with this format
> >> of MSI messages, but this system implemented a stricter interpretation
> >> of the spec, and so even though that system doesn't need a quirk for MSI
> >> because MSI works in general, we still MUST test the MSI vector to make
> >> sure it works *for us*  In this case it comes down to being an errata
> >> workaround.
> >>
> >> Since there is no way to "test" generation of an interrupt from any
> >> specific hardware device without internal knowledge of said device,
> >> there isn't a way for us to help the kernel by writing a generic "test
> >> MSI" routine.
> >>
> >> I would prefer this "generic test" code be in the driver rather than
> >> having to identify all the chipsets that fail and have the driver do
> >> *specific chipset* detection ala bnx2.c's 8132 bridge workaround.
> >>
> >>>> The platforms with MSI problems should be discovered, made public,
> >>>> and worked around. 
> >> This is our workaround, it is our fault, the incompatible chipset is in
> >> an x3850 IBM system.
> >>
> > 
> > I've seem similar problems on other systems, so this would be a nice bit
> > of code to have somewhere.  I can see Jeff's argument for having this
> > outside of drivers, but to make my life easier I'd like to see this in
> > e1000e (and e1000!).  :-)
> 
> e1000 will soon no longer support PCI Express devices, so this is unneeded.
> 

So you plan to drop the bits around the device additions that are
related to e1000e config sometime soon?
