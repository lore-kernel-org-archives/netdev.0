From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 11:14:34 -0800
Message-ID: <47A21E1A.6000006@hp.com>
References: <20080131124632.GA25299@basil.nowhere.org>	<47A212CB.1060403@hp.com>	<20080131190326.GF4671@one.firstfloor.org>	<47A214FE.3050200@hp.com> <20080131192521.GG4671@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:22280 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758534AbYAaTOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 14:14:36 -0500
In-Reply-To: <20080131192521.GG4671@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
>>So, at what timescale do people using these qdiscs expect things to 
>>appear "smooth?"  64KB of data at GbE speeds is something just north of 
>>half a millisecond unless I've botched my units somewhere.
> 
> 
> One typical use case for TBF is you talking to a DSL bridge that 
> is connected using a GBit Ethernet switch. For these DSL connections it gives
> much better behaviour to shape the traffic to slightly below
> your external link speed so that you can e.g. prioritize packets properly.

Sounds like the functionality needs to be in the DSL bridge :) (or the 
"router" in the same case) Particularly since it might be getting used 
by more than one host on the GbE switch.

> But the actual external link speed is much lower than GbE.
> A lot of GbE NICs enable TSO by default.

bluesky typing...

then the qdisc could/should place a cap on the size of a 'TSO' based on 
the bitrate (and perhaps input as to how much time any one "burst" of 
data should be allowed to consume on the network) and pass that up the 
stack?  right now you seem to be proposing what is effectively a cap of 
1 MSS.

rick jones
