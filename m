From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net-next] net: Assert napi_gro_cb size against
 skb->cb[]
Date: Fri, 31 Jul 2015 13:44:42 -0700 (PDT)
Message-ID: <20150731.134442.1572308169975939249.davem@davemloft.net>
References: <1438368669-659-1-git-send-email-f.fainelli@gmail.com>
	<20150731202403.GB20471@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, daniel@iogearbox.net,
	edumazet@google.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbbGaUoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 16:44:46 -0400
In-Reply-To: <20150731202403.GB20471@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 31 Jul 2015 22:24:03 +0200

> Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 64-bits hosts, napi_gro_cb is 48 bytes, which is exactly the size of
>> skb->cb[], while on 32-bits hosts it is 36 bytes, but if it were to
>> grow, we would not be catching a size inflation as we should.
>> ---
>>  net/core/dev.c | 2 ++
>>  1 file changed, 2 insertions(+)
>> 
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 4870c3556a5a..20bc82604b75 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -4115,6 +4115,8 @@ static void skb_gro_reset_offset(struct sk_buff *skb)
>>  	const struct skb_shared_info *pinfo = skb_shinfo(skb);
>>  	const skb_frag_t *frag0 = &pinfo->frags[0];
>>  
>> +	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct napi_gro_cb));
> 
> commit c3c7c254b2e8cd99b0adf288c2a1bddacd7ba255
> already added a check for this.

Indeed.
