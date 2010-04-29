From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH RFC: linux-next 1/2] irq: Add CPU mask affinity hint
 callback framework
Date: Thu, 29 Apr 2010 22:39:45 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1004292237280.2951@localhost.localdomain>
References: <20100419045741.30276.23233.stgit@ppwaskie-hc2.jf.intel.com>  <alpine.LFD.2.00.1004271425140.2951@localhost.localdomain>  <Pine.WNT.4.64.1004270856560.320@PPWASKIE-MOBL2.amr.corp.intel.com>  <alpine.LFD.2.00.1004271809080.2951@localhost.localdomain>
  <1272563946.9614.1.camel@localhost>  <alpine.LFD.2.00.1004292121310.2951@localhost.localdomain> <1272572930.9614.3.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:36196 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932593Ab0D3RMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 13:12:46 -0400
In-Reply-To: <1272572930.9614.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Apr 2010, Peter P Waskiewicz Jr wrote:
> On Thu, 2010-04-29 at 12:48 -0700, Thomas Gleixner wrote:
> > Thinking more about it, I wonder whether you have a cpu_mask in your
> > driver/device private data anyway. I bet you have :)
> 
> Well, at this point we don't, but nothing says we can't.

Somewhere you need to store that information in your driver, right ?

> > So it should be sufficient to set a pointer to that cpu_mask in
> > irq_desc and get rid of the callback completely.
> 
> So "register" would just assign the pointer, and "unregister" would make
> sure to NULL the mask pointer out.  I like it.  It'll sure clean things
> up too.

Yep, that'd be like the set_irq_chip() function. Just assign the
pointer under desc->lock.

Thanks,

	tglx
