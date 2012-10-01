From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] use skb_end_offset() in skb_try_coalesce()
Date: Mon, 01 Oct 2012 16:46:16 -0400 (EDT)
Message-ID: <20121001.164616.1621118658519526629.davem@davemloft.net>
References: <6f3540c213735f009409d1cc7d3fe0dea91469d9.1348899174.git.wpan@redhat.com>
	<1349112517.12401.715.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wpan@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756587Ab2JAUqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 16:46:18 -0400
In-Reply-To: <1349112517.12401.715.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 01 Oct 2012 19:28:37 +0200

> On Sat, 2012-09-29 at 14:15 +0800, Weiping Pan wrote:
>> Commit ec47ea824774(skb: Add inline helper for getting the skb end offset from
>> head) introduces this helper function, skb_end_offset(),
>> we should make use of it.
>> 
>> Signed-off-by: Weiping Pan <wpan@redhat.com>
>> ---
>>  net/core/skbuff.c |    3 +--
>>  1 files changed, 1 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index e33ebae..86f040a 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -3488,8 +3488,7 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
>>  		    skb_shinfo(from)->nr_frags > MAX_SKB_FRAGS)
>>  			return false;
>>  
>> -		delta = from->truesize -
>> -			SKB_TRUESIZE(skb_end_pointer(from) - from->head);
>> +		delta = from->truesize - SKB_TRUESIZE(skb_end_offset(from));
>>  	}
>>  
>>  	WARN_ON_ONCE(delta < len);
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
