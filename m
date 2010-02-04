From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] NAPI as kobject proposal
Date: Wed, 3 Feb 2010 17:58:46 -0800
Message-ID: <20100203175846.545d7e56@nehalam>
References: <20100129101839.36944ba5@nehalam>
	<20100203.173305.196876047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60265 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752198Ab0BDB6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2010 20:58:53 -0500
In-Reply-To: <20100203.173305.196876047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 03 Feb 2010 17:33:05 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 29 Jan 2010 10:18:39 -0800
> 
> > As part of receive packet steering there is a requirement to add an
> > additional parameter to this for the CPU map.
> 
> Hmmm, where did this come from?
> 
> The RPS maps are per-device.
> 
> I think I vaguely recall you "suggesting" that the RPS maps become
> per-NAPI.
> 
> But, firstly, I didn't see any movement in that part of the
> discussion.
> 
> And, secondly, I don't think this makes any sense at all.
> 
> Things are already overly complicated as it is.  Having the user know
> what traffic goes to a particular RX queue (ie. NAPI instance) and set
> the RPS map in some way specific to that RX queue is over the top.
> 
> If the issue is the case of sharing a NAPI instance between two
> devices, there are a few other ways to deal with this.
> 
> One I would suggest is to simply clone the RPS map amongst the
> devices sharing a NAPI instance.
> 
> I currently see NAPI kobjects is just an over-abstraction for a
> perceived need rather than a real one.

It started with doing RPS, and not wanting to implement the proposed
sysfs interface (anything doing get_token is misuse of sysfs).

The usage model I see is wanting to have:
  1. only some cores being used for receive traffic
     on single Rx devices (NAPI)
  2. only some cores being used for receive traffic
     on legacy devices (non-NAPI)
  3. being able to configure a set of cpus with same   
     IRQ/cache when doing Rx multi-queue.  Assign MSI-X
     IRQ per core and allow both HT on core to split
     that RX traffic.

All this should be manageable by some user utility like irqbalance.

#1 and #2 argue for a per device map (like irq_affinity) but
#3 is harder; not sure the right API for that.

