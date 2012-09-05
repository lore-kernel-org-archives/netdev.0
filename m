From: a1 <a1bert@atlas.cz>
Subject: Re: [Bug 47021] New: kernel panic with l2tpv3 & mtu > 1500
Date: Wed, 05 Sep 2012 09:45:40 +0200
Message-ID: <50470324.5040805@atlas.cz>
References: <20120904090756.71b34feb@nehalam.linuxnetplumber.net> <1346788334.13121.82.camel@edumazet-glaptop> <20120904125458.7d97ec38@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gmmr8.centrum.cz ([46.255.227.254]:36425 "EHLO gmmr8.centrum.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752011Ab2IEHv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 03:51:59 -0400
In-Reply-To: <20120904125458.7d97ec38@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, it definitely helped, no more panics now...

jn

>>>
>>
>> Seems following patch is needed, not sure if it helps
>>
>> [PATCH] l2tp: fix a typo in l2tp_eth_dev_recv()
>>
>> While investigating l2tp bug, I hit a bug in eth_type_trans(),
>> because not enough bytes were pulled in skb head.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> ---
>>  net/l2tp/l2tp_eth.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
>> index f9ee74d..3bfb34a 100644
>> --- a/net/l2tp/l2tp_eth.c
>> +++ b/net/l2tp/l2tp_eth.c
>> @@ -153,7 +153,7 @@ static void l2tp_eth_dev_recv(struct l2tp_session *session, struct sk_buff *skb,
>>  		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, skb->data, length);
>>  	}
>>  
>> -	if (!pskb_may_pull(skb, sizeof(ETH_HLEN)))
>> +	if (!pskb_may_pull(skb, ETH_HLEN))
>>  		goto error;
> 
> I guess nobody ever looked inside this code. That seems like an obvious bug.
> 
