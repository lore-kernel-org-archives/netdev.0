From: Jeba Anandhan <jeba.anandhan@vaioni.com>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Thu, 10 Jan 2008 16:51:36 +0000
Message-ID: <1199983896.29856.48.camel@vglwks010.vgl2.office.vaioni.com>
References: <1199981839.8931.35.camel@cafe>
	 <20080110163626.GJ3544@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Breno Leitao <leitao@linux.vnet.ibm.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vglsrv002.office.vaioni.com ([84.19.35.12]:4206 "EHLO
	vglsrv02.vgl2.office.vaioni.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758763AbYAJQxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 11:53:14 -0500
In-Reply-To: <20080110163626.GJ3544@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben,
I am facing the performance issue when we try to bond the multiple
interfaces with virtual interface. It could be related to this thread. 
My questions are,
*) When we use mulitple NICs, will the performance of overall system  be
summation of all individual lines  XX bits/sec. ?
*) What are the factors improves the performance if we have multiple
interfaces?. [ kind of tuning the parameters in proc ]

Breno, 
I hope this thread will be helpful for performance issue which i have
with bonding driver.

Jeba
On Thu, 2008-01-10 at 16:36 +0000, Ben Hutchings wrote:
> Breno Leitao wrote:
> > Hello, 
> > 
> > I've perceived that there is a performance issue when running netperf
> > against 4 e1000 links connected end-to-end to another machine with 4
> > e1000 interfaces. 
> > 
> > I have 2 4-port interfaces on my machine, but the test is just
> > considering 2 port for each interfaces card.
> > 
> > When I run netperf in just one interface, I get 940.95 * 10^6 bits/sec
> > of transfer rate. If I run 4 netperf against 4 different interfaces, I
> > get around 720 * 10^6 bits/sec.
> <snip>
> 
> I take it that's the average for individual interfaces, not the
> aggregate?  RX processing for multi-gigabits per second can be quite
> expensive.  This can be mitigated by interrupt moderation and NAPI
> polling, jumbo frames (MTU >1500) and/or Large Receive Offload (LRO).
> I don't think e1000 hardware does LRO, but the driver could presumably
> be changed use Linux's software LRO.
> 
> Even with these optimisations, if all RX processing is done on a
> single CPU this can become a bottleneck.  Does the test system have
> multiple CPUs?  Are IRQs for the multiple NICs balanced across
> multiple CPUs?
> 
> Ben.
> 
