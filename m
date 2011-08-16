From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: add Documentation/networking/scaling.txt
Date: Tue, 16 Aug 2011 20:53:24 +0100
Message-ID: <1313524404.2725.50.camel@bwh-desktop>
References: <alpine.DEB.2.00.1107312346350.28722@pokey.mtv.corp.google.com>
	 <4E36F524.7090301@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, rdunlap@xenotime.net,
	linux-doc@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, willemb@google.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:53943 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043Ab1HPTxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 15:53:30 -0400
In-Reply-To: <4E36F524.7090301@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-08-01 at 11:49 -0700, Rick Jones wrote:
> On 07/31/2011 11:56 PM, Tom Herbert wrote:
> > Describes RSS, RPS, RFS, accelerated RFS, and XPS.
> >
> > Signed-off-by: Tom Herbert<therbert@google.com>
> > ---
> >   Documentation/networking/scaling.txt |  346 ++++++++++++++++++++++++++++++++++
> >   1 files changed, 346 insertions(+), 0 deletions(-)
> >   create mode 100644 Documentation/networking/scaling.txt
> >
> > diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
> > new file mode 100644
> > index 0000000..aa51f0f
> > --- /dev/null
> > +++ b/Documentation/networking/scaling.txt
> > @@ -0,0 +1,346 @@
> > +Scaling in the Linux Networking Stack
> > +
> > +
> > +Introduction
> > +============
> > +
> > +This document describes a set of complementary techniques in the Linux
> > +networking stack to increase parallelism and improve performance (in
> > +throughput, latency, CPU utilization, etc.) for multi-processor systems.
> 
> Why not just leave-out the parenthetical lest some picky pedant find a 
> specific example where either of those three are not improved?

As I'm sure you're aware, there is often a trade-off between throughput
and latency.  It might be useful to provide some guidelines for
optimising each of the above.

[...]
> > +== RSS IRQ Configuration
> > +
> > +Each receive queue has a separate IRQ associated with it. The NIC
> > +triggers this to notify a CPU when new packets arrive on the given
> > +queue. The signaling path for PCIe devices uses message signaled
> > +interrupts (MSI-X), that can route each interrupt to a particular CPU.
> > +The active mapping of queues to IRQs can be determined from
> > +/proc/interrupts. By default, all IRQs are routed to CPU0.  Because a
> 
> Really?

The default affinity for most IRQs is all-CPUs.  At least on x86, that
really means CPU 0 only, so far as I can see.

[...]
> > +== Accelerated RFS Configuration
> > +
> > +Accelerated RFS is only available if the kernel is compiled with
> > +CONFIG_RFS_ACCEL and support is provided by the NIC device and driver.
> > +It also requires that ntuple filtering is enabled via ethtool.
> 
> Requires that ntuple filtering be enabled?
[...]

As a matter of fact, n-tuple filtering is enabled by default where
available.  So it might actually make more sense to say that RFS
acceleration can be *disabled* by disabling n-tuple filtering using
ethtool.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

