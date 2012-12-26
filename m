From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH V2] ipv6 mcast: Fix incorrect use of pskb_may_pull().
Date: Thu, 27 Dec 2012 01:40:07 +0900
Message-ID: <50DB2867.20000@linux-ipv6.org>
References: <50DA6B0D.6010500@linux-ipv6.org> <1356537792.20133.20451.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:40402 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752819Ab2LZQkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 11:40:10 -0500
In-Reply-To: <1356537792.20133.20451.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> On Wed, 2012-12-26 at 12:12 +0900, YOSHIFUJI Hideaki wrote:
>> pskb_may_pull(skb, len) ensures that len bytes from skb->data
>> are available in a linear array.  When pskb_may_pull() is
>> being used multiple times for the same buffer without
>> skb_pull(), the length is not accumulated.
:
>> @@ -1124,7 +1124,7 @@ int igmp6_event_query(struct sk_buff *skb)
>>  	int mark = 0;
>>  	int len;
>>  
>> -	if (!pskb_may_pull(skb, sizeof(struct in6_addr)))
>> +	if (!pskb_may_pull(skb, sizeof(struct icmp6hdr) + sizeof(struct in6_addr)))
>>  		return -EINVAL;
>>  
> 
> I am a bit confused by your patch.
> 
> igmp6_event_query() is called from icmpv6_rcv() _after_ 
> 
> pskb_pull(skb, sizeof(*hdr);
> 
> (hdr being struct icmp6hdr)
> 
> So this patch is wrong IMHO

Argh..I agree.  I withdraw this one.

--yoshfuji
