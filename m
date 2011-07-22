From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next-2.6] ipv6: make fragment identifications less
 predictable
Date: Thu, 21 Jul 2011 17:34:22 -0700
Message-ID: <4E28C58E.1080501@hp.com>
References: <1311150327.2338.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	<1311157648.2338.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	<4E2781A2.8020905@gont.com.ar>	<20110721.151750.995903739612693126.davem@davemloft.net> <4E28B84C.2090305@gont.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	security@kernel.org, eugeneteo@kernel.sg, netdev@vger.kernel.org,
	mpm@selenic.com
To: Fernando Gont <fernando@gont.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:38931 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816Ab1GVAeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 20:34:25 -0400
In-Reply-To: <4E28B84C.2090305@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/2011 04:37 PM, Fernando Gont wrote:
> On 07/21/2011 07:17 PM, David Miller wrote:
>>> Does it make sense to go in this direction rather than simply randomize
>>> the IPv6 Fragment Identification?
>>
>> We could, but that's actually a bit more work.
>>
>> You have to avoid recycling IDs to the same destination host otherwise
>> a retransmit could use the same ID and overlap with a previous set of
>> frags, causing corruption.
>>
>> This means if you go the "pure random" route, you have to make sure
>> that the 32-bit series produced by the random number generator is
>> maximally long.  This is why openbsd uses an ID generator based upon
>> skip32 etc.
>
> That scenario assumes packet reordering and/or packet loss.

Isn't that a given?  I mean if there were no packet reordering or packet 
loss then the size of the ID space wouldn't matter right? The fragments 
would be sent, in order and without loss and all would be happiness and 
joy.  It is only because there is packet reordering and/or packet loss 
that we care about the size of the ID space and the time to reuse of a 
given ID.

And indeed, fragmentation is considered bad, and was considered bad 
enough that the "revenge of the router guys" that is IPv6 punted it to 
the end systems, and yes, one should use PMTUD. Which is all well and 
good when 999 times out of 1 traffic is flowing over a transport that 
does its own segmentation and reassembly.  And when IPv6 got spec'ed it 
looked to all the world that UDP was on the way out - NFS was migrating 
over to TCP, and DNS was "never" more than 512 byte messages. No problem 
right?  But since then we've gotten things like EDNS which will be 
sending DNS messages in UDP datagrams that will have to be fragmented, 
PMTUD notwithstanding.

rick jones
almost certainly fumbled a TLA in there somewhere :)
