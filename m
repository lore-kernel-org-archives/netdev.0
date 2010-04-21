From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: crash with bridge and inconsistent handling of NETDEV_TX_OK
Date: Tue, 20 Apr 2010 21:10:04 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.1004202108240.27476@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1004202003010.13651@hs20-bc2-1.build.redhat.com>
 <20100420.171525.200010343.davem@davemloft.net>
 <Pine.LNX.4.64.1004202018100.16302@hs20-bc2-1.build.redhat.com>
 <20100420.180253.159346294.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53386 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754071Ab0DUBKP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 21:10:15 -0400
In-Reply-To: <20100420.180253.159346294.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Apr 2010, David Miller wrote:

> From: Mikulas Patocka <mpatocka@redhat.com>
> Date: Tue, 20 Apr 2010 20:23:57 -0400 (EDT)
> 
> > I have two NICs, each with 1500 MTU. The stack trace indicates that a 
> > packet was received by one NIC and bridged to the other. The stack trace 
> > also indicates that it went through GSO code path. The question is why? 
> > How could a forwarded packet be so large to use GSO?
> 
> GRO automatically accumulates packets together, accumulating them into
> larger super-packets.  This is done regardless of input device feeding
> it.
> 
> Can you understand this now?  In software, we accumulate all incoming
> packets for a TCP stream into larger super-packets.  Just because it's
> a bridging scenerio doesn't mean we disable GRO.
> 
> These super-packets are being bridged, then forwarded out your
> destination device and GSO has to de-segment these GRO frames.
> 
> GRO is done unconditionally, all the time, for all packets.

I see, but GRO is turned off on my interfaces, according to ethtool.

Mikulas
