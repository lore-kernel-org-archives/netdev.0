From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Tue, 6 Jun 2006 18:17:27 -0500
Message-ID: <20060606231727.GK24227@waste.org>
References: <20060605230917.12584.55755.stgit@gitlost.site> <20060605231125.12584.17039.stgit@gitlost.site> <20060606135217.GA21969@hmsreliant.homelinux.net> <1149611965.13635.19.camel@strongmad> <20060606170513.GB21969@hmsreliant.homelinux.net> <4485B8EC.4090603@intel.com> <x494pyyw5sr.fsf@segfault.boston.redhat.com> <4485BCA2.5070904@intel.com> <x49zmgquqn0.fsf@segfault.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([64.81.244.121]:62879 "EHLO waste.org")
	by vger.kernel.org with ESMTP id S1751352AbWFFX11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 19:27:27 -0400
To: Jeff Moyer <jmoyer@redhat.com>
Content-Disposition: inline
In-Reply-To: <x49zmgquqn0.fsf@segfault.boston.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 06, 2006 at 01:42:59PM -0400, Jeff Moyer wrote:
> ==> Regarding Re: [PATCH 1/2] e1000: fix netpoll with NAPI; Auke Kok <auke-jan.h.kok@intel.com> adds:
> 
> auke-jan.h.kok> Jeff Moyer wrote:
> >> ==> Regarding Re: [PATCH 1/2] e1000: fix netpoll with NAPI; Auke Kok <auke-jan.h.kok@intel.com> adds:
> auke-jan.h.kok> Neil Horman wrote:
> >>>> On Tue, Jun 06, 2006 at 09:39:25AM -0700, Mitch Williams wrote:
> >>>>> On Tue, 2006-06-06 at 09:52 -0400, Neil Horman wrote:
> auke-jan.h.kok> [snip]
> >> 
> >>>>> However, just for the sake of correctness (and paranoia), I'll whip up
> >>>>> another patch that does this check.
> >>>>> 
> >>>> Thanks for the quick feedback!
> >>>> Regards
> >>>> Neil
> >>>> 
> >>>>> Jeff, please do not commit this patch.
> auke-jan.h.kok> Jeff,
> auke-jan.h.kok> I've popped the patch off from our gitserver, so you can
> >> pull the two
> auke-jan.h.kok> outstanding patches while we revamp this one.
> >> Would you please send patches to this list?  I'd certainly like to review
> >> them.  I don't think the problem needs solving in the e1000 driver.  I
> >> think it is an issue that should be handled properly by netpoll.
> 
> auke-jan.h.kok> ???
> 
> auke-jan.h.kok> that message was directed to Jeff Garzik, perhaps that was too confusing.
> 
> I figured it was directed at Jeff G.
> 
> auke-jan.h.kok> They were sent here in the first place:
> 
> auke-jan.h.kok> http://marc.theaimsgroup.com/?l=linux-netdev&m=114954878711789&w=2
> 
> Thanks for the pointer.
> 
> As you noted, e1000 now uses a separate device for polling.  Netpoll should
> be able to deal with this, though.  I'd like to solicit mpm's input on
> this, as I'm having difficulties coming up with a clean solution.

It's a bit ad-hoc at the moment, but it might be a step towards a
cleaner model. 

> For some background, the netpoll_poll_lock calls were introduced to prevent
> recursion in a device driver's ->poll routine.  By essentially calling the
> poll routine from the poll_controller routine, you are no longer prevented
> from such recursion.
> 
> It would be best if the poll_controller routine was kept simple.  It should
> do the equivalent of the interrupt processing portion of the work, and
> leave the delivery to the network stack for a call to the ->poll routine.
> 
> Solving this at the netpoll layer will be a bit difficult, since we have no
> insight into the driver design (as your driver illustrates).  Up until now,
> our model worked well.

That's probably an overstatement.
 
> We could, potentially, walk the list of devices scheduled for a poll much
> the same as net_rx_action does.  However, we don't want to process work
> pending on other network adapters, only the one associated with the netpoll
> net device.  I can think of at least one way to make this distinction, but
> it feels too much like a hack.

Processing work on other devices may not be completely wrong. 
 
> Matt, any ideas on this?

Not at the moment.

-- 
Mathematics is the supreme nostalgia of our time.
