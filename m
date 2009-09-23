From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: Getting physical packet counts with LRO enabled with ixgbe?
Date: Wed, 23 Sep 2009 11:32:46 -0700
Message-ID: <1253730766.2538.28.camel@localhost.localdomain>
References: <4ABA4F8B.6040504@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56552 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709AbZIWScu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 14:32:50 -0400
In-Reply-To: <4ABA4F8B.6040504@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-09-23 at 09:40 -0700, Ben Greear wrote:
> I notice that with LRO enabled, the interface stats count the LRO'd pkts,
> not the physical ones on the wire.
> 
> I also tried using ethtool -S, but it seems those counters are the same.
> 
> Is there any way to get the actual rx/tx packet count on the wire?
> 

Depending on which device you're using ixgbe with, there are slightly
different registers to get what you want.

The only suggestion I have for you though is to refer to the datasheets
for each device on our SourceForge site (e1000.sf.net).  Some of the
relevant counters to look at are PRC64, PRC127, etc, and GPRC/GPTC.  For
the per-queue stuff, you'll need to look at the TQSMR and RQSMR mapping
registers.  Let me know if you need assistance in using these registers.

> Also, for the rx/tx bytes, I assume that isn't counting the protocol headers
> for the physical pkts that have been merged into a single LRO packet.  Is
> there any way to get the wire stats for bytes as well?

The counters for per-byte are purely software-based, so if the packet is
LRO'd, you can probably do some somewhat trivial math with the MTU to
find the actual wire stats.  But we only compute what we pass to the
stack, so it'd be the LRO'd packet.

Cheers,
-PJ Waskiewicz

