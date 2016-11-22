From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6:ipv6_pinfo dereferenced after NULL check
Date: Tue, 22 Nov 2016 10:06:13 -0500 (EST)
Message-ID: <20161122.100613.2091017686933180253.davem@davemloft.net>
References: <1479796024-39418-1-git-send-email-manjeet.p@samsung.com>
        <611c167e-cef4-691b-f154-1b6b6aa86e53@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manjeet.p@samsung.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, pankaj.m@samsung.com,
        ajeet.y@samsung.com, r.thapliyal@samsung.com
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <611c167e-cef4-691b-f154-1b6b6aa86e53@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 22 Nov 2016 13:26:45 +0100

> On 22.11.2016 07:27, Manjeet Pawar wrote:
>> From: Rohit Thapliyal <r.thapliyal@samsung.com>
>> 
>> np checked for NULL and then dereferenced. It should be modified
>> for NULL case.
>> 
>> Signed-off-by: Rohit Thapliyal <r.thapliyal@samsung.com>
>> Signed-off-by: Manjeet Pawar <manjeet.p@samsung.com>
>> ---
>>  net/ipv6/ip6_output.c | 9 +++++----
>>  1 file changed, 5 insertions(+), 4 deletions(-)
>> 
>> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
>> index 1dfc402..c2afa14 100644
>> --- a/net/ipv6/ip6_output.c
>> +++ b/net/ipv6/ip6_output.c
>> @@ -205,14 +205,15 @@ int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
>>  	/*
>>  	 *	Fill in the IPv6 header
>>  	 */
>> -	if (np)
>> +	if (np) {
>>  		hlimit = np->hop_limit;
>> +		ip6_flow_hdr(
>> +					hdr, tclass, ip6_make_flowlabel(
>> +					net, skb, fl6->flowlabel,
>> +					np->autoflowlabel, fl6));
>> +	}
>>  	if (hlimit < 0)
>>  		hlimit = ip6_dst_hoplimit(dst);
>>  
>> -	ip6_flow_hdr(hdr, tclass, ip6_make_flowlabel(net, skb, fl6->flowlabel,
>> -				np->autoflowlabel, fl6));
>> -
>>  	hdr->payload_len = htons(seg_len);
>>  	hdr->nexthdr = proto;
>>  	hdr->hop_limit = hlimit;
>> 
> 
> 
> We always should initialize hdr and not skip the ip6_flow_hdr call.
> 
> Do you saw a bug or did you find this by code review? I wonder if np can
> actually be NULL at this point. Maybe we can just eliminate the NULL check.

Also the indentation is really off.
