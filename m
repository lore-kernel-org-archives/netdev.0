From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Thu, 10 Jan 2008 16:36:27 +0000
Message-ID: <20080110163626.GJ3544@solarflare.com>
References: <1199981839.8931.35.camel@cafe>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rutherford.zen.co.uk ([212.23.3.142]:49431 "EHLO
	rutherford.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754129AbYAJQgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 11:36:31 -0500
Content-Disposition: inline
In-Reply-To: <1199981839.8931.35.camel@cafe>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Breno Leitao wrote:
> Hello, 
> 
> I've perceived that there is a performance issue when running netperf
> against 4 e1000 links connected end-to-end to another machine with 4
> e1000 interfaces. 
> 
> I have 2 4-port interfaces on my machine, but the test is just
> considering 2 port for each interfaces card.
> 
> When I run netperf in just one interface, I get 940.95 * 10^6 bits/sec
> of transfer rate. If I run 4 netperf against 4 different interfaces, I
> get around 720 * 10^6 bits/sec.
<snip>

I take it that's the average for individual interfaces, not the
aggregate?  RX processing for multi-gigabits per second can be quite
expensive.  This can be mitigated by interrupt moderation and NAPI
polling, jumbo frames (MTU >1500) and/or Large Receive Offload (LRO).
I don't think e1000 hardware does LRO, but the driver could presumably
be changed use Linux's software LRO.

Even with these optimisations, if all RX processing is done on a
single CPU this can become a bottleneck.  Does the test system have
multiple CPUs?  Are IRQs for the multiple NICs balanced across
multiple CPUs?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
