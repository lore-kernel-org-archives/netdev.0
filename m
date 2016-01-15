From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netfilter: xt_TCPMSS: handle CHECKSUM_COMPLETE in
 tcpmss_tg6()
Date: Fri, 15 Jan 2016 14:04:49 -0500 (EST)
Message-ID: <20160115.140449.1324683966791337294.davem@davemloft.net>
References: <1452874892.1223.175.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S348Td5ZHVDTOn+DudAjs9pNjhs6kkEbn-CgYCqXEh0BQg@mail.gmail.com>
	<1452878324.1223.188.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, pablo@netfilter.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1452878324.1223.188.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Jan 2016 09:18:44 -0800

> On Fri, 2016-01-15 at 08:43 -0800, Tom Herbert wrote:
> 
>> Probably should have a utility function do this. Maybe something like
>> update_hdr_field(skb, old, new)? Could return new value so above could
>> just be:
>> 
>> ipv6h->payload_len = update_hdr_field(skb, ipv6h->payload_len,
>> htons(ntohs(oldlen) + ret);
> 
> Well, oldlen would still need to be ipv6h->payload_len
> 
> Not sure a helper will be nice for a stable submission.
> 
> Probably better for net-next ?

Agreed.  We already have those csum_replace{2,4}() helpers in net/checksum.h
which we could augment with ones that can handle length changes too.
