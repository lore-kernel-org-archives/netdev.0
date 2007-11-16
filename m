From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 6/6 net-2.6.25][RAW] Consolidate proc interface
Date: Fri, 16 Nov 2007 17:39:21 +0300
Message-ID: <473DAB99.7060903@openvz.org>
References: <473DA6EF.5090004@openvz.org> <20071116.232455.82345485.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, devel@openvz.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44712 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752130AbXKPOji (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 09:39:38 -0500
In-Reply-To: <20071116.232455.82345485.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki wrote:
> NAK.
> 
> In article <473DA6EF.5090004@openvz.org> (at Fri, 16 Nov 2007 17:19:27 +0300), Pavel Emelyanov <xemul@openvz.org> says:
> 
>> @@ -858,7 +852,7 @@ static struct sock *raw_get_first(struct seq_file *seq)
>>  			++state->bucket) {
>>  		struct hlist_node *node;
>>  
>> -		sk_for_each(sk, node, &raw_v4_hashinfo.ht[state->bucket])
>> +		sk_for_each(sk, node, &state->h->ht[state->bucket])
>>  			if (sk->sk_family == PF_INET)
>>  				goto found;
>>  	}
> 
> This and
> 
>> -static struct sock *raw6_get_first(struct seq_file *seq)
>> -{
>> -	struct sock *sk;
>> -	struct hlist_node *node;
>> -	struct raw6_iter_state* state = raw6_seq_private(seq);
>> -
>> -	for (state->bucket = 0; state->bucket < RAW_HTABLE_SIZE;
>> -			++state->bucket)
>> -		sk_for_each(sk, node, &raw_v6_hashinfo.ht[state->bucket])
>> -			if (sk->sk_family == PF_INET6)
>> -				goto out;
>> -	sk = NULL;
>> -out:
>> -	return sk;
>> -}
>> -
> 
> this are different.

Oops... Indeed. Thanks for noticing. I've overlooked this :(

> --yoshfuji
> 

