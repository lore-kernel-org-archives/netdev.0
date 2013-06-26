From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v2 net-next 2/2] sit: add support of x-netns
Date: Tue, 25 Jun 2013 18:35:30 -0700
Message-ID: <87d2r964d9.fsf@xmission.com>
References: <51C9A4E3.2060906@6wind.com>
	<1372170295-4717-1-git-send-email-nicolas.dichtel@6wind.com>
	<1372170295-4717-3-git-send-email-nicolas.dichtel@6wind.com>
	<20130625.165612.1653110297729408070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out04.mta.xmission.com ([166.70.13.234]:57968 "EHLO
	out04.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144Ab3FZBgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 21:36:10 -0400
In-Reply-To: <20130625.165612.1653110297729408070.davem@davemloft.net> (David
	Miller's message of "Tue, 25 Jun 2013 16:56:12 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Tue, 25 Jun 2013 16:24:55 +0200
>
>> @@ -453,6 +454,8 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
>>  	tstats->rx_bytes += skb->len;
>>  	u64_stats_update_end(&tstats->syncp);
>>  
>> +	skb_scrub_packet(skb);
>> +
>>  	if (tunnel->dev->type == ARPHRD_ETHER) {
>>  		skb->protocol = eth_type_trans(skb, tunnel->dev);
>>  		skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
>
> I can't see how this can be ok.
>
> If something in netfilter depends upon the state you are clearing out
> here, someone's packet filtering setup is going to break.
>
> I'm not applying these patches, sorry.

How can netfilter depend on the state of a packet inside of a tunnel?

How can it even make sense?

Or is your concern that we unintentionally allowed this in the past so
to avoid breaking binary compatibility we should continue in case
someone somewhere cares?

I really can't see how this could possibly be an intentional feature.

Eric
