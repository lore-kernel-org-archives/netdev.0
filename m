From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 19/19] sfc: Add SR-IOV back-end support for
 SFC9000 family
Date: Thu, 16 Feb 2012 01:57:19 +0000
Message-ID: <1329357439.3048.115.camel@deadeye>
References: <1329352938.2565.26.camel@bwh-desktop>
	 <1329353550.2565.45.camel@bwh-desktop> <4F3C595A.3020401@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>,
	Shradha Shah <sshah@solarflare.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:58172 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756668Ab2BPB5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 20:57:18 -0500
In-Reply-To: <4F3C595A.3020401@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-15 at 17:18 -0800, John Fastabend wrote:
> On 2/15/2012 4:52 PM, Ben Hutchings wrote:
> > On the SFC9000 family, each port has 1024 Virtual Interfaces (VIs),
> > each with an RX queue, a TX queue, an event queue and a mailbox
> > register.  These may be assigned to up to 127 SR-IOV virtual functions
> > per port, with up to 64 VIs per VF.
> > 
> > We allocate an extra channel (IRQ and event queue only) to receive
> > requests from VF drivers.
> > 
> > There is a per-port limit of 4 concurrent RX queue flushes, and queue
> > flushes may be initiated by the MC in response to a Function Level
> > Reset (FLR) of a VF.  Therefore, when SR-IOV is in use, we submit all
> > flush requests via the MC.
> > 
> > The RSS indirection table is shared with VFs, so the number of RX
> > queues used in the PF is limited to the number of VIs per VF.
> > 
> > This is almost entirely the work of Steve Hodgson, formerly
> > shodgson@solarflare.com.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> 
> Hi Ben,
> 
> So how would multiple VIs per VF work? Looks like each VI has a TX/RX
> pair all bundled under a single netdev with some set of TX MAC filters.

They can be used to provide a multiqueue net device for use in multi-
processor guests.

> Do you expect users to build tc rules and edit the queue_mapping to get
> the skb headed at the correct tx queue? Would it be better to model each
> VI has its own net device.

No, we expect users to assign the VF into the guest.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
