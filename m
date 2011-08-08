From: Rick Jones <rick.jones2@hp.com>
Subject: Re: 802.3ad bonding brain damaged?
Date: Mon, 08 Aug 2011 13:54:59 -0700
Message-ID: <4E404D23.8020008@hp.com>
References: <4E3EECF6.90409@cfl.rr.com>	<1312790234.7020.26.camel@arkology.n2.diac24.net> <4E4041B5.5040908@cfl.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Phillip Susi <psusi@cfl.rr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:7985 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418Ab1HHUzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 16:55:00 -0400
In-Reply-To: <4E4041B5.5040908@cfl.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2011 01:06 PM, Phillip Susi wrote:
> On 8/8/2011 3:57 AM, David Lamparter wrote:
>> No, it isn't. 802.3ad/.1AX explicitly requires that no packet
>> re-ordering may ever occur, which can only be guaranteed by enqueueing
>> packets for one host on one TX interface. This behaviour is mandated by
>> 802.1AX-2008 page 15 which reads:
>
> Outch, that does cause a big problem for store-and-forward switching.
> You basically can't split up packets from a single stream without very
> careful cut-through switching, which we obviously can't do in Linux.
> That seems a rather silly requirement given that higher level protocols
> already deal with packet reordering. Why not an option to say stuff the
> standard?


At even in the case of protocols that deal with packet reordering, it is 
still quite possible to be sub-optimal.  Try running a TCP_STREAM test 
through a mode-rr bond with 4 or more links in it.  I suspect that even 
without injecting the occasional "other" packet there can be enough 
re-ordering to trigger spurious fast retransmissions.  At the very least 
it will trigger lots of immediate ACKnowledgements, which will drive-up 
the CPU utilization per KB transferred.  And if these spread packets 
arrive still spread at the receiver, round-robin will probably preclude 
effective GRO and certainly preclude LRO.

Apart from some very carefully controlled conditions, if one needs a 
single flow to go faster than a single link, it is probably time to move 
up to the next higher link speed.

rick jones
