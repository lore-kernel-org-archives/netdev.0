From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 23 Nov 2015 17:11:03 -0800
Message-ID: <20151123171103.00007699@unknown>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
	<1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
	<CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
	<CAEh+42jWN961Gg59xbdXiFj9u7=3vuFdyXkcr6iPJ92ZizPpGw@mail.gmail.com>
	<C40BE8378EF49C44B9184714DBC8EF29939A13AA@ORSMSX115.amr.corp.intel.com>
	<CALx6S36H4eyDg-Vv21X2GaGA+g=KfN6iHX=8uM2isEOnPTjs0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Singhai, Anjali" <anjali.singhai@intel.com>,
	Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Patil, Kiran" <kiran.patil@intel.com>, jesse.brandeburg@intel.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:46967 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752321AbbKXBLE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 20:11:04 -0500
In-Reply-To: <CALx6S36H4eyDg-Vv21X2GaGA+g=KfN6iHX=8uM2isEOnPTjs0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Nov 2015 16:38:59 -0800
Tom Herbert <tom@herbertland.com> wrote:
> >> >
> >> > Sorry, I still don't like this. Grant it least it gets rid of of VXLAN
> >> > specific ops, but the problem is there no such things as a common set
> >> > of encapsulations in the kernel (e.g. foo-over-udp adds a bunch of
> >> > encapsulations not represented here), no defined common set of device

Tom, thanks for your feedback.

Is anyone using foo-over-udp besides you?
I know a lot of people using VxLAN and many who want Geneve offloads.
The performance gain of using hardware offload in this area is
non-trivial (like 300% or more)

> >> > functionality that needs this, and this precludes the use of the RX
> >> > accelerations to be available from a userpsace  implementation.
> >>
> >> Regardless, I think this is at least a good cleanup of what is already
> >> there compared to having VXLAN-specific NDOs. We can always add
> >> additional things in the future.
> >
> > Agreed with Jesse that this will help not hurt,  when we are ready to 
> > cross the bridge for removing RX side Protocol ossification.
> >
> The time is now to address the protocol ossification problem. HW
> vendors leaking out support for random protocols one at a time really
> isn't helpful at all. Unfortunately, it's pretty clear that many
> vendors aren't going to fix this on their own volition. Fixing the
> interfaces to "encourage" change seems to be a way we can help things
> a long from kernel perspective.

So we (as a kernel community) have users *NOW* who want this
feature, and hardware that is available *now* that has this feature.
Do you think we should wait for a unicorn to arrive that has a fully
programmable de-ossified checksum engine?  How long?

Agree that we can start to address the Protocol Ossification problem by
working with hardware vendors, but that is a multi-year process to get
to new silicon with these changes.  Those with fully programmable
firmware engines might be able to get a change done sooner, but that
requires a non-trivial effort by the vendor that isn't reusable in
other operating systems, or maybe isn't possible at all due to hardware
limits.

FWIW, I've brought the issue to the attention of the architects here,
and we will likely be able to make changes in this space.  Intel
hardware (as demonstrated by your patches) already is able to deal with
this de-ossification on transmit.  Receive is a whole different beast.

I think that trying to force an agenda with no fore-warning and also
punishing the users in order to get hardware vendors to change is the
wrong way to go about this.  All you end up with is people just asking
you why their hardware doesn't work in the kernel.

You have a proposal, let's codify it and enable it for the future, and
especially be *really* clear what you want hardware vendors to
implement so that they get it right.  MS does this by publishing
specifications and being clear what MUST be implemented and what COULD
be implemented.
