From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: distribute vxlan tunneled traffic
 across multiple TXQs
Date: Tue, 31 Dec 2013 13:56:36 -0500 (EST)
Message-ID: <20131231.135636.1587787263812667419.davem@davemloft.net>
References: <1387803413-22152-1-git-send-email-sathya.perla@emulex.com>
	<20131223112854.572b11aa@nehalam.linuxnetplumber.net>
	<1387910346.12212.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, sathya.perla@emulex.com,
	netdev@vger.kernel.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755650Ab3LaS4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 13:56:38 -0500
In-Reply-To: <1387910346.12212.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Dec 2013 10:39:06 -0800

> On Mon, 2013-12-23 at 11:28 -0800, Stephen Hemminger wrote:
> 
>> The idea is good, but without the destructor there is nothing to keep
>> the UDP socket from being destroyed while packet is being sent on another
>> CPU.
> 
> I see no requirement of holding a reference on the vxlan UDP socket in
> transmit path.

I'm trying to figure out how leaving a dangling socket attached to
skb->sk, as in this original patch, can be OK.

If skb->sk is there, anyone can reference it, and meanwhile anyone can
destroy and free it.

That's Stephens' objection.

Are you saying that we have something that allows this to be valid?
