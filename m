From: David Miller <davem@davemloft.net>
Subject: Re: crash with bridge and inconsistent handling of NETDEV_TX_OK
Date: Tue, 20 Apr 2010 18:02:53 -0700 (PDT)
Message-ID: <20100420.180253.159346294.davem@davemloft.net>
References: <Pine.LNX.4.64.1004202003010.13651@hs20-bc2-1.build.redhat.com>
	<20100420.171525.200010343.davem@davemloft.net>
	<Pine.LNX.4.64.1004202018100.16302@hs20-bc2-1.build.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: mpatocka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51698
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754258Ab0DUBCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 21:02:48 -0400
In-Reply-To: <Pine.LNX.4.64.1004202018100.16302@hs20-bc2-1.build.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 20 Apr 2010 20:23:57 -0400 (EDT)

> I have two NICs, each with 1500 MTU. The stack trace indicates that a 
> packet was received by one NIC and bridged to the other. The stack trace 
> also indicates that it went through GSO code path. The question is why? 
> How could a forwarded packet be so large to use GSO?

GRO automatically accumulates packets together, accumulating them into
larger super-packets.  This is done regardless of input device feeding
it.

Can you understand this now?  In software, we accumulate all incoming
packets for a TCP stream into larger super-packets.  Just because it's
a bridging scenerio doesn't mean we disable GRO.

These super-packets are being bridged, then forwarded out your
destination device and GSO has to de-segment these GRO frames.

GRO is done unconditionally, all the time, for all packets.
