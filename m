From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 7 Jun 2007 09:08:40 -0700
Message-ID: <20070607090840.346f6a09@localhost.localdomain>
References: <D5C1322C3E673F459512FB59E0DDC32902FC61BF@orsmsx414.amr.corp.intel.com>
	<20070606.154041.08321169.davem@davemloft.net>
	<1181172946.4064.87.camel@localhost>
	<20070606.165602.118948582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42374 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752790AbXFGQJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 12:09:45 -0400
In-Reply-To: <20070606.165602.118948582.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 06 Jun 2007 16:56:02 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: jamal <hadi@cyberus.ca>
> Date: Wed, 06 Jun 2007 19:35:46 -0400
> 
> > There is no potential for parallelizing on transmit that i can think of.
> > Dave, please explain it slowly so i can understand it.
> > 
> > There is huge potential for parallelizing on receive. But i am certainly
> > missing the value in the transmit.
> 
> I gave an example in another response, you have N processes
> queueing up data for TCP or UDP or whatever in parallel on
> different cpus, all going out the same 10gbit device.
> 
> All of them enter into ->hard_start_xmit(), and thus all of them try
> to take the same netdev->tx_lock
> 
> If they have multiple TX queues, independantly programmable, that
> single lock is stupid.
> 
> We could use per-queue TX locks for such hardware, but we can't
> support that currently.

There could be bad packet reordering with this (like some SMP routers used to do).

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
