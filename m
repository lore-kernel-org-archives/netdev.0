From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/5] [VLAN]: Unclassified vlan packet
Date: Tue, 27 May 2008 08:30:23 +0200
Message-ID: <483BAA7F.6060408@trash.net>
References: <20080411135714.GA8137@tp64> <483B9EBE.5030703@trash.net> <b25c3fa70805262320h7edb4246wd017261fe7187b88@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43874 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754994AbYE0Ga1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 02:30:27 -0400
In-Reply-To: <b25c3fa70805262320h7edb4246wd017261fe7187b88@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
> 2008/5/26 Patrick McHardy <kaber@trash.net>:
>> Joonwoo Park wrote:
>>> To be polite to the PACKET,
>>> Don't kill the unclassified & hardware accelerated vlan packets if netdev
>>> is in promiscuous, set packet type with PACKET_OTHERHOST. Put the vlan tag
>>> into skb->cb for all hardware accelerated vlan packets.
>> Conceptually I think this patch goes in the right direction,
>> one question remaining is when to invalidate the VLAN tag again.
>>
>> The only solution I could come up with is invalidating it in
>> netif_receive_skb() when the receiving device is not a VLAN
>> device and additionally invalidating it in all callers of
>> dev_queue_xmit except VLAN itself, but I would really prefer
>> something less error prone without touching netif_receive_skb().
>>
>> BTW, I already have a patch queued to move the VLAN tag from
>> skb->cb to a seperate skb member to fix the the conflict with
>> qdiscs (this should also allow to use vlan accel through virtual
>> network devices later on). So please don't resend, I'll integrate
>> the patch on top of this change once we find a good spot for
>> invalidation.
>>
> 
> Thanks Patrick for reviewing.
> I'll be looking forward to seeing it on the list.


Well, we still need to find a good spot for invalidation.
Suggestions welcome :)
