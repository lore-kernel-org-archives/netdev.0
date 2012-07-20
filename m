From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/16] ipv4: Kill rt->rt_oif
Date: Fri, 20 Jul 2012 13:31:15 -0700 (PDT)
Message-ID: <20120720.133115.1828569805175844233.davem@davemloft.net>
References: <20120719.143616.1125314165355374962.davem@davemloft.net>
	<alpine.LFD.2.00.1207200219010.5516@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380Ab2GTUbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 16:31:16 -0400
In-Reply-To: <alpine.LFD.2.00.1207200219010.5516@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Fri, 20 Jul 2012 04:10:12 +0300 (EEST)

>> @@ -1795,7 +1795,6 @@ static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct sk_buff *skb)
>>  		.daddr = iph->daddr,
>>  		.saddr = iph->saddr,
>>  		.flowi4_tos = RT_TOS(iph->tos),
>> -		.flowi4_oif = rt->rt_oif,
>>  		.flowi4_iif = rt->rt_iif,
>>  		.flowi4_mark = skb->mark,
> 
> 	But it was wrong at first place to use rt_iif
> here. May be we should provide devices to "mrule" just
> like we do for "rule", with the only difference that
> oif now is possible to match outdev instead of preferred
> device, i.e. oif is always set for output routes.
> 
> 	.flowi4_oif = rt_is_output_route(rt) ?
> 			skb->dev->ifindex : 0,
> 	.flowi4_iif = rt_is_output_route(rt) ?
> 			net->loopback_dev->ifindex :
> 			skb->dev->ifindex;

Ok.

> 	Let me know if patch is needed

I'll take care of it myself today, thanks.
