From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6/ip6_gre: fix error case handling in
 ip6gre_tunnel_xmit()
Date: Wed, 06 Feb 2013 16:02:36 -0500 (EST)
Message-ID: <20130206.160236.144295308153323655.davem@davemloft.net>
References: <1360157042-16473-1-git-send-email-tt.rantala@gmail.com>
	<1360157395.28557.30.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tt.rantala@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	xeb@mail.ru
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755294Ab3BFVCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 16:02:39 -0500
In-Reply-To: <1360157395.28557.30.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Feb 2013 05:29:55 -0800

> On Wed, 2013-02-06 at 15:24 +0200, Tommi Rantala wrote:
>> ip6gre_tunnel_xmit() is leaking the skb when we hit this error branch,
>> and the -1 return value from this function is bogus. Use the error
>> handling we already have in place in ip6gre_tunnel_xmit() for this error
>> case to fix this.
>> 
>> Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>
>> ---
>>  net/ipv6/ip6_gre.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
>> index c727e47..131dd09 100644
>> --- a/net/ipv6/ip6_gre.c
>> +++ b/net/ipv6/ip6_gre.c
>> @@ -960,7 +960,7 @@ static netdev_tx_t ip6gre_tunnel_xmit(struct sk_buff *skb,
>>  	int ret;
>>  
>>  	if (!ip6_tnl_xmit_ctl(t))
>> -		return -1;
>> +		goto tx_err;
>>  
>>  	switch (skb->protocol) {
>>  	case htons(ETH_P_IP):
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
