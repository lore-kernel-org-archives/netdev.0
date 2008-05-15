From: "Kingsley Foreman" <kingsley@internode.com.au>
Subject: Re: NET_SCHED cbq dropping too many packets on a bonding interface
Date: Fri, 16 May 2008 06:57:23 +0930
Message-ID: <1A70765F4B30462EB21A3B3A8A442633@uglypunk>
References: <20080515091216.GA6550@ff.dom.local> <8ECDBB4EB5394859BFFACAAEE3A6EDB0@uglypunk> <482C6040.9030808@trash.net> <20080515182504.GB2936@ami.dom.local> <482C81CC.7000305@trash.net> <20080515184646.GC2936@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Jarek Poplawski" <jarkao2@gmail.com>,
	"Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail05.adl2.internode.on.net ([203.16.214.145]:53363 "EHLO
	ipmail05.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752667AbYEOV1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 17:27:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--------------------------------------------------
From: "Jarek Poplawski" <jarkao2@gmail.com>
Sent: Friday, May 16, 2008 4:16 AM
To: "Patrick McHardy" <kaber@trash.net>
Cc: "Kingsley Foreman" <kingsley@internode.com.au>; "Eric Dumazet" 
<dada1@cosmosbay.com>; "Andrew Morton" <akpm@linux-foundation.org>; 
<linux-kernel@vger.kernel.org>; <netdev@vger.kernel.org>
Subject: Re: NET_SCHED cbq dropping too many packets on a bonding interface

> On Thu, May 15, 2008 at 08:32:44PM +0200, Patrick McHardy wrote:
>> Jarek Poplawski wrote:
>>> On Thu, May 15, 2008 at 06:09:36PM +0200, Patrick McHardy wrote:
>>> ...
>>>> Do things improve if you set txqueuelen to a larger value
>>>> *before* configuring the qdiscs?
>>>
>>> BTW, I hope it was *before*, but since pfifo_fast_enqueue() uses
>>> "qdisc->dev->tx_queue_len" does it really matter? (Until it's
>>> before the test of course...)
>>
>>
>> Yes, CBQ uses pfifo, not pfifo_fast. pfifo uses txqueuelen
>> to inialize q->limit, but thats whats used during ->enqueue().
>
> ...My bad! I missed this and this (only!?) seems to explain this
> puzzle. So, I hope it was really because *not before* (and not only
> size matters...)
>
> Thanks,
> Jarek P.
>

running

tc qdisc add dev bond0 root pfifo limit 1000

or

tc qdisc add dev bond0 root handle 1: cbq bandwidth 2000Mbit avpkt 1000 cell 
0
tc qdisc add dev bond0 parent 1: pfifo limit 1000


doesn't appear to be dropping packets. 

