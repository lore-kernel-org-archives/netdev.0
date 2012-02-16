From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 19/19] sfc: Add SR-IOV back-end support for SFC9000
 family
Date: Wed, 15 Feb 2012 17:18:18 -0800
Message-ID: <4F3C595A.3020401@intel.com>
References: <1329352938.2565.26.camel@bwh-desktop> <1329353550.2565.45.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Shradha Shah <sshah@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22552 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751891Ab2BPBRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 20:17:53 -0500
In-Reply-To: <1329353550.2565.45.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/15/2012 4:52 PM, Ben Hutchings wrote:
> On the SFC9000 family, each port has 1024 Virtual Interfaces (VIs),
> each with an RX queue, a TX queue, an event queue and a mailbox
> register.  These may be assigned to up to 127 SR-IOV virtual functions
> per port, with up to 64 VIs per VF.
> 
> We allocate an extra channel (IRQ and event queue only) to receive
> requests from VF drivers.
> 
> There is a per-port limit of 4 concurrent RX queue flushes, and queue
> flushes may be initiated by the MC in response to a Function Level
> Reset (FLR) of a VF.  Therefore, when SR-IOV is in use, we submit all
> flush requests via the MC.
> 
> The RSS indirection table is shared with VFs, so the number of RX
> queues used in the PF is limited to the number of VIs per VF.
> 
> This is almost entirely the work of Steve Hodgson, formerly
> shodgson@solarflare.com.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---

Hi Ben,

So how would multiple VIs per VF work? Looks like each VI has a TX/RX
pair all bundled under a single netdev with some set of TX MAC filters.

Do you expect users to build tc rules and edit the queue_mapping to get
the skb headed at the correct tx queue? Would it be better to model each
VI has its own net device.

Thanks,
John
