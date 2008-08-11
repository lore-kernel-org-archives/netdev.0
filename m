From: Eugene Teo <eteo@redhat.com>
Subject: Re: OOPS, ip -f inet6 route get fec0::1, linux-2.6.26,	ip6_route_output,
 rt6_fill_node+0x175
Date: Mon, 11 Aug 2008 16:40:24 +0800
Message-ID: <489FFAF8.3000909@redhat.com>
References: <9F6ACAE02B6DD040A1E259977622CFDB033590C3@oslexcp1.eu.tandberg.int> <20080807203748.GA5196@martell.zuzino.mipt.ru> <489BD227.6000209@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	John Gumb <john.gumb@tandberg.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable@kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49994 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752638AbYHKIlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 04:41:18 -0400
In-Reply-To: <489BD227.6000209@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley wrote:
> Alexey Dobriyan wrote:
>> On Thu, Aug 07, 2008 at 07:00:56PM +0200, John Gumb wrote:
>>> Scenario: no ipv6 default route set.
>>
>>> # ip -f inet6 route get fec0::1
>>>
>>> BUG: unable to handle kernel NULL pointer dereference at 00000000
>>> IP: [<c0369b85>] rt6_fill_node+0x175/0x3b0
>>> EIP is at rt6_fill_node+0x175/0x3b0
>>
>> 0xffffffff80424dd3 is in rt6_fill_node (net/ipv6/route.c:2191).
>> 2186                    } else
>> 2187    #endif
>> 2188                            NLA_PUT_U32(skb, RTA_IIF, iif);
>> 2189            } else if (dst) {
>> 2190                    struct in6_addr saddr_buf;
>> 2191      ====>         if
>> (ipv6_dev_get_saddr(ip6_dst_idev(&rt->u.dst)->dev,
>>                            ^^^^^^^^^^^^^^^^^^^^^^^^
>>                                    NULL
>>
>> 2192                                           dst, 0, &saddr_buf) == 0)
>> 2193                            NLA_PUT(skb, RTA_PREFSRC, 16,
>> &saddr_buf);
>> 2194            }
> 
> The commit that changed this can't be reverted easily, but the patch
> below works for me.
> 
> Fix NULL de-reference in rt6_fill_node() when there's no IPv6 input
> device present in the dst entry.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Cc: Stable <stable@kernel.org>

Eugene
