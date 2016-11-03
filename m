From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Thu, 3 Nov 2016 10:44:51 +0100
Message-ID: <fbbb6241-f95f-88cd-fee8-78dd42f78321@stressinduktion.org>
References: <1478118977-19608-1-git-send-email-lrichard@redhat.com>
 <20161103094239.13ac8ac2@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, jtluka@redhat.com
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:43511 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753287AbcKCJo4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 05:44:56 -0400
In-Reply-To: <20161103094239.13ac8ac2@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.11.2016 08:42, Shmulik Ladkani wrote:
> On Wed,  2 Nov 2016 16:36:17 -0400
> Lance Richardson <lrichard@redhat.com> wrote:
> 
>> -	/* common case: fragmentation of segments is not allowed,
>> -	 * or seglen is <= mtu
>> +	/* common case: seglen is <= mtu
>>  	 */
>> -	if (((IPCB(skb)->flags & IPSKB_FRAG_SEGS) == 0) ||
>> -	      skb_gso_validate_mtu(skb, mtu))
>> +	if (skb_gso_validate_mtu(skb, mtu))
>>  		return ip_finish_output2(net, sk, skb);
> 
> OK.
> Resembles https://patchwork.ozlabs.org/patch/644724/ ;)
> 
>> -	if (skb_iif && !(df & htons(IP_DF))) {
>> -		/* Arrived from an ingress interface, got encapsulated, with
>> -		 * fragmentation of encapulating frames allowed.
>> -		 * If skb is gso, the resulting encapsulated network segments
>> -		 * may exceed dst mtu.
>> -		 * Allow IP Fragmentation of segments.
>> -		 */
>> -		IPCB(skb)->flags |= IPSKB_FRAG_SEGS;
>> -	}
> 
> The only potential issue I see removing this, is that the KNOWLEDGE of
> the forwarding/tunnel-bridging usecases (that require a
> skb_gso_validate_mtu check) is lost.
> 
> Meaning, if one decides (as claimed in the past) that locally generated
> traffic must NOT go through fragmentation validation, then no one
> remembers those other valid usecases (which are very specific and not
> trivial to imagine) that MUST go through it; Therefore it can easily get
> broken.

I agree but I think the git changelog reassembles the changes in this
area in good enough detail and it can be added if there is need for that
currently I don't see a reason why to leave this code there.

I am a bit sad to remove this condition, but the alternative, to
generate oversized frames, is absolutely not acceptable. :/

Thanks,
Hannes
