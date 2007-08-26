From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Sun, 26 Aug 2007 20:36:20 +0100
Message-ID: <46D1D634.7060007@katalix.com>
References: <200708241747.16592.ossthema@de.ibm.com>	<20070824085203.42f4305c@freepuppy.rosehill.hemminger.net>	<46CF127D.1090609@katalix.com> <20070824.144711.18301866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, ossthema@de.ibm.com,
	akepner@sgi.com, netdev@vger.kernel.org, raisch@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, meder@de.ibm.com, tklein@de.ibm.com,
	stefan.roscher@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:59058 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752065AbXHZTlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Aug 2007 15:41:25 -0400
In-Reply-To: <20070824.144711.18301866.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Fri, 24 Aug 2007 18:16:45 +0100
> 
>> Does hardware interrupt mitigation really interact well with NAPI?
> 
> It interacts quite excellently.

If NAPI disables interrupts and keeps them disabled while there are more 
packets arriving or more transmits being completed, why do hardware 
interrupt mitigation / coalescing features of the network silicon help?

> There was a long saga about this with tg3 and huge SGI numa
> systems with large costs for interrupt processing, and the
> fix was to do a minimal amount of interrupt mitigation and
> this basically cleared up all the problems.
> 
> Someone should reference that thread _now_ before this discussion goes
> too far and we repeat a lot of information and people like myself have
> to stay up all night correcting the misinformation and
> misunderstandings that are basically guarenteed for this topic :)

I hope I'm not spreading misinformation. :) The original poster was 
observing NAPI going in/out of polled mode because the CPU is fast 
enough to process all work per poll. I've seen the same and I'm 
suggesting that the NAPI driver keeps itself in polled mode for N polls 
or M jiffies after it sees workdone=0. This has always worked for me in 
packet forwarding scenarios to maximize packets/sec and minimize 
latency. I'm considering putting a patch together to add this as another 
tuning knob, hence I'm keen to understand what I'm missing. :)

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

