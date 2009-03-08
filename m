From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] igb: fix kexec with igb
Date: Sun, 8 Mar 2009 11:45:51 +0100
Message-ID: <200903081145.52408.rjw@sisk.pl>
References: <49B1F934.5050006@kernel.org> <m1ocwddwjp.fsf@fess.ebiederm.org> <86802c440903071050y453c7648x653d3e2073a33c1e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:33464 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751010AbZCHKqI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Mar 2009 06:46:08 -0400
In-Reply-To: <86802c440903071050y453c7648x653d3e2073a33c1e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 07 March 2009, Yinghai Lu wrote:
> On Sat, Mar 7, 2009 at 10:20 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
> > Yinghai Lu <yinghai@kernel.org> writes:
> >
> >> On Fri, Mar 6, 2009 at 11:18 PM, Jesse Brandeburg
> >> <jesse.brandeburg@gmail.com> wrote:
> >>> On Fri, Mar 6, 2009 at 8:33 PM, Yinghai Lu <yinghai@kernel.org> wrote:
> >>>>
> >>>> Impact: could probe igb
> >>>>
> >>>> Found one system with 82575EB, in the kernel that is kexeced, probe igb
> >>>> failed with -2.
> >>>>
> >>>> it looks like the same behavior happened on forcedeth.
> >>>>
> >>>> try to check system_state to make sure if put it on D3
> >>>>
> >>>> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> >>>>
> >>>> ---
> >>>>  drivers/net/igb/igb_main.c |   19 ++++++++++++++-----
> >>>>  1 file changed, 14 insertions(+), 5 deletions(-)
> >>>
> >>> I see the point of the patch, but I know for a fact that ixgbe when
> >>> enabled for MSI-X also doesn't work with kexec.
> >>>
> >>> so my questions are:
> >>> are you going to change every driver?
> >>
> >> i tend to only change driver that i have related HW.
> >>
> >>> why can't this be fixed in core kernel code instead?
> >> will check it.
> >>
> >>> Shouldn't pci_enable_device take it out of D3?
> >>> Or maybe it should be taken out of D3 immediately if someone tries to
> >>> ioremap any of the BARx registers?
> >>
> >>
> >> looks like second kernel can not detect the state any more.
> >
> > I know this has historically been a problem with the e1000 NICs.
> > Placing the hardware in a state they can not get them out of on
> > the reboot path.
> >
> > Last I heard (a couple of weeks ago?) we had code to bring devices out
> > of a low power state that was working for the e1000 driver.
> 
> in net-next tree?
> 
> >
> > YH can you look and see if you can find that code and if it works?
> 
> it seems e1000 and e1000e works well for a long time.
> 
> >
> > <rant>
> > Frankly I don't understand why anyone would want to power down a device
> > when they are rebooting or shutting down a computer.  That is a
> > system state change.  But it seems to be bleed over from the confusion
> > that has been the power management code.
> > </rant>
> 
> agreed.

Well, well.

IMHO, the confusion is that ->shutdown() is used for too many _different_
things, because kexec is sufficiently different from power off, for example, to
be handled by a separate driver callback.  I'm totally unsure what power
management has to do with it, though.

Thanks,
Rafael
