From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Wed, 12 Sep 2007 16:02:39 +0200
Message-ID: <20070912160239.70a580e8@oldman>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>
	<1189120020.4259.68.camel@localhost>
	<46E11A61.9030409@katalix.com>
	<1189171370.4234.38.camel@localhost>
	<20070912030428.16059af6.billfink@mindspring.com>
	<1189599142.4326.38.camel@localhost>
	<46E7EE89.9060006@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Bill Fink <billfink@mindspring.com>,
	netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	mandeep.baines@gmail.com, ossthema@de.ibm.com
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56061 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757610AbXILOCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 10:02:54 -0400
In-Reply-To: <46E7EE89.9060006@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Sep 2007 14:50:01 +0100
James Chapman <jchapman@katalix.com> wrote:

> jamal wrote:
> > On Wed, 2007-12-09 at 03:04 -0400, Bill Fink wrote:
> >> On Fri, 07 Sep 2007, jamal wrote:
> > 
> >>> I am going to be the devil's advocate[1]:
> >> So let me be the angel's advocate.  :-)
> > 
> > I think this would make you God's advocate ;->
> > (http://en.wikipedia.org/wiki/God%27s_advocate)
> > 
> >> I view his results much more favorably.  
> > 
> > The challenge is, under _low traffic_: bad bad CPU use.
> > Thats what is at stake, correct?
> 
> By low traffic, I assume you mean a rate at which the NAPI driver 
> doesn't stay in polled mode. The problem is that that rate is getting 
> higher all the time, as interface and CPU speeds increase. This results 
> in too many interrupts and NAPI thrashing in/out of polled mode very 
> quickly.

But if you compare this to non-NAPI driver the same softirq
overhead happens. The problem is that for many older devices disabling IRQ's
require an expensive non-cached PCI access. Smarter, newer devices
all use MSI which is pure edge triggered and with proper register
usage, NAPI should be no worse than non-NAPI.
