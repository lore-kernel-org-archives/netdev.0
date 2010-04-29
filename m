From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH RFC: linux-next 1/2] irq: Add CPU mask affinity hint
 callback framework
Date: Thu, 29 Apr 2010 14:29:10 -0700
Message-ID: <1272576550.9614.51.camel@localhost>
References: <20100419045741.30276.23233.stgit@ppwaskie-hc2.jf.intel.com>
	 <alpine.LFD.2.00.1004271425140.2951@localhost.localdomain>
	 <Pine.WNT.4.64.1004270856560.320@PPWASKIE-MOBL2.amr.corp.intel.com>
	 <alpine.LFD.2.00.1004271809080.2951@localhost.localdomain>
	 <1272563946.9614.1.camel@localhost>
	 <alpine.LFD.2.00.1004292121310.2951@localhost.localdomain>
	 <1272572930.9614.3.camel@localhost>
	 <alpine.LFD.2.00.1004292237280.2951@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:28902 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758599Ab0D3Rja (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 13:39:30 -0400
In-Reply-To: <alpine.LFD.2.00.1004292237280.2951@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-29 at 13:39 -0700, Thomas Gleixner wrote:
> On Thu, 29 Apr 2010, Peter P Waskiewicz Jr wrote:
> > On Thu, 2010-04-29 at 12:48 -0700, Thomas Gleixner wrote:
> > > Thinking more about it, I wonder whether you have a cpu_mask in your
> > > driver/device private data anyway. I bet you have :)
> > 
> > Well, at this point we don't, but nothing says we can't.
> 
> Somewhere you need to store that information in your driver, right ?

Yes.  But right now, storing a cpu_mask for an interrupt wouldn't buy us
anything since we have no mechanism to make use of it today.  :-)

I'll be putting the cpu_mask entry in our q_vector structure, which is
our abstraction of the MSI-X vector (it's where I have the hint struct
right now in patch 2/2 for the ixgbe driver).  It's a simple place to
stick it.

> > > So it should be sufficient to set a pointer to that cpu_mask in
> > > irq_desc and get rid of the callback completely.
> > 
> > So "register" would just assign the pointer, and "unregister" would make
> > sure to NULL the mask pointer out.  I like it.  It'll sure clean things
> > up too.
> 
> Yep, that'd be like the set_irq_chip() function. Just assign the
> pointer under desc->lock.
> 
> Thanks,
> 
> 	tglx


