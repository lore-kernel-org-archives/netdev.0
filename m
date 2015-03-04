From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 0/6] net: Call skb_get_hash in qdiscs
Date: Wed, 4 Mar 2015 13:49:38 -0800
Message-ID: <CA+mtBx8Y+AQ5nc5B=qvBZnJOpgTVy0Q6VFMR3r9t6MPrGb5gRA@mail.gmail.com>
References: <1425494404-24114-1-git-send-email-therbert@google.com>
	<1425499383.5130.227.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:46490 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbbCDVtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 16:49:39 -0500
Received: by iery20 with SMTP id y20so17558443ier.13
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 13:49:38 -0800 (PST)
In-Reply-To: <1425499383.5130.227.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 4, 2015 at 12:03 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-03-04 at 10:39 -0800, Tom Herbert wrote:
>
>> - The flow keys are passed in cb[] structure. This severely limits
>>   our ability to increase the key space. For instance, the folding
>>   of IPv6 addresses in flow_dissector to make a 32-bit value
>>   represents a significant loss of information (it would be easy
>>   to create millions of different 4-tuples that would always produce the
>>   same hash value).
>
>
> Yes, but then your patch is all about reducing flow compares to a single
> u32 comparison in qdiscs (and elsewhere)
>
> choke for example explicitly wants to make sure we drop a companion
> if incoming packet belongs to the same flow.
>
> Relying on a 'strong hash' whatever it can be was not considered in
> Choke paper. There is no mention of a stochastic match.
>
Then choke is broke :-) ipv6_addr_hash already makes the "flow" match
stochastic.

> If we no longer can store the keys in skb->cb[], fine (although I claim
> skb->cb[] size should be irrelevant, see our discussion on this topic
> with Florian)
>  -> Just recompute the keys, using a local variable, from packet
> content. Yes, it will be more expensive, but hey, we get what we want.
>
> Same for sfq : your skb_get_hash_perturb() doesn't address the point I
> made earlier.
>
> It is only giving a false sense of security.
> I would rather not spread it.
> (Note that there is no documentation or changelog to explain the
> pro/cons)
>
> I doubt OVS would condense their flow keys in a single u32...
>
>
