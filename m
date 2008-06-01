From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 1/5] [VLAN]: Unclassified vlan packet
Date: Sun, 1 Jun 2008 15:16:56 -0700
Message-ID: <b25c3fa70806011516q7ae6c913q9d6e431d664d176e@mail.gmail.com>
References: <20080411135714.GA8137@tp64> <483B9EBE.5030703@trash.net>
	 <b25c3fa70805262320h7edb4246wd017261fe7187b88@mail.gmail.com>
	 <483BAA7F.6060408@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:20920 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474AbYFAWQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 18:16:57 -0400
Received: by rv-out-0506.google.com with SMTP id l9so748431rvb.1
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2008 15:16:56 -0700 (PDT)
In-Reply-To: <483BAA7F.6060408@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/5/26 Patrick McHardy <kaber@trash.net>:
> Joonwoo Park wrote:
>>
>> 2008/5/26 Patrick McHardy <kaber@trash.net>:
>>>
>>> Joonwoo Park wrote:
>>>>
>>>> To be polite to the PACKET,
>>>> Don't kill the unclassified & hardware accelerated vlan packets if
>>>> netdev
>>>> is in promiscuous, set packet type with PACKET_OTHERHOST. Put the vlan
>>>> tag
>>>> into skb->cb for all hardware accelerated vlan packets.
>>>
>>> Conceptually I think this patch goes in the right direction,
>>> one question remaining is when to invalidate the VLAN tag again.
>>>
>>> The only solution I could come up with is invalidating it in
>>> netif_receive_skb() when the receiving device is not a VLAN
>>> device and additionally invalidating it in all callers of
>>> dev_queue_xmit except VLAN itself, but I would really prefer
>>> something less error prone without touching netif_receive_skb().
>>>
>>> BTW, I already have a patch queued to move the VLAN tag from
>>> skb->cb to a seperate skb member to fix the the conflict with
>>> qdiscs (this should also allow to use vlan accel through virtual
>>> network devices later on). So please don't resend, I'll integrate
>>> the patch on top of this change once we find a good spot for
>>> invalidation.
>>>
>>
>> Thanks Patrick for reviewing.
>> I'll be looking forward to seeing it on the list.
>
>
> Well, we still need to find a good spot for invalidation.
> Suggestions welcome :)
>

Patrick,
Do you mind inserting a new flag to indicate vlan_tag is just for
af_packet or not into sk_buff?
I think if flag exists, we can pass vlan_tag to af_packet with just
modifications of vlan_get_tag(), vlan_put_tag() and
vlan_tag_present(),
without patching for invalidation.

Thanks,
Joonwoo
