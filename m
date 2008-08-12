From: Eugene Teo <eugeneteo@kernel.sg>
Subject: Re: OOPS, ip -f inet6 route get fec0::1, linux-2.6.26, ip6_route_output,
 rt6_fill_node+0x175
Date: Tue, 12 Aug 2008 08:13:40 +0800
Message-ID: <48A0D5B4.9050908@kernel.sg>
References: <20080807203748.GA5196@martell.zuzino.mipt.ru>	<489BD227.6000209@hp.com>	<489FFAF8.3000909@redhat.com> <20080811.135003.105171324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, adobriyan@gmail.com, john.gumb@tandberg.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	parag.warudkar@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45597 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753051AbYHLAOI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 20:14:08 -0400
In-Reply-To: <20080811.135003.105171324.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Eugene Teo <eteo@redhat.com>
> Date: Mon, 11 Aug 2008 16:40:24 +0800
> 
>> Brian Haley wrote:
>>> Alexey Dobriyan wrote:
>>>> On Thu, Aug 07, 2008 at 07:00:56PM +0200, John Gumb wrote:
>>>>> Scenario: no ipv6 default route set.
>>>>> # ip -f inet6 route get fec0::1
>>>>>
>>>>> BUG: unable to handle kernel NULL pointer dereference at 00000000
>>>>> IP: [<c0369b85>] rt6_fill_node+0x175/0x3b0
>>>>> EIP is at rt6_fill_node+0x175/0x3b0
>>>> 0xffffffff80424dd3 is in rt6_fill_node (net/ipv6/route.c:2191).
>>>> 2186                    } else
>>>> 2187    #endif
>>>> 2188                            NLA_PUT_U32(skb, RTA_IIF, iif);
>>>> 2189            } else if (dst) {
>>>> 2190                    struct in6_addr saddr_buf;
>>>> 2191      ====>         if
>>>> (ipv6_dev_get_saddr(ip6_dst_idev(&rt->u.dst)->dev,
>>>>                            ^^^^^^^^^^^^^^^^^^^^^^^^
>>>>                                    NULL
>>>>
>>>> 2192                                           dst, 0, &saddr_buf) == 0)
>>>> 2193                            NLA_PUT(skb, RTA_PREFSRC, 16,
>>>> &saddr_buf);
>>>> 2194            }
>>> The commit that changed this can't be reverted easily, but the patch
>>> below works for me.
>>>
>>> Fix NULL de-reference in rt6_fill_node() when there's no IPv6 input
>>> device present in the dst entry.
>>>
>>> Signed-off-by: Brian Haley <brian.haley@hp.com>
>> Cc: Stable <stable@kernel.org>
> 
> We've already determined from one tester that the behavior is
> changing with Brian's patch.  Furthermore I haven't applied it
> to mainline so it isn't anywhere near being submittable for
> -stable.

With the patch I posted, this is the behaviour I get:

$ ip -f inet6 route get fec0::1
unreachable fec0::1 dev lo  table unspec  proto none  src
fe80::214:4fff:fe0f:7332  metric -1  error -101 hoplimit 255

John emailed me that he will be testing this patch. I have not tested
Brian's patch.

> I submit all relevant networking bug fixes to -stable when they are
> ready and in a proper state to be submitted, you don't have to do it
> for me.  Sending me a gentle reminder or nudge, on the other hand, is
> fine.

Thanks for letting me know. I wasn't familiar, but I welcome the hint.

Thanks,
Eugene
