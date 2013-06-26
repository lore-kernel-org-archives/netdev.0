From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v2 net-next 2/2] sit: add support of x-netns
Date: Wed, 26 Jun 2013 03:03:22 -0700
Message-ID: <87ppv942ad.fsf@xmission.com>
References: <1372170295-4717-3-git-send-email-nicolas.dichtel@6wind.com>
	<20130625.165612.1653110297729408070.davem@davemloft.net>
	<87d2r964d9.fsf@xmission.com>
	<20130625.224810.293452557691677283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:56665 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542Ab3FZKD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 06:03:58 -0400
In-Reply-To: <20130625.224810.293452557691677283.davem@davemloft.net> (David
	Miller's message of "Tue, 25 Jun 2013 22:48:10 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 25 Jun 2013 18:35:30 -0700
>
>> David Miller <davem@davemloft.net> writes:
>> 
>>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>> Date: Tue, 25 Jun 2013 16:24:55 +0200
>>>
>>>> @@ -453,6 +454,8 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
>>>>  	tstats->rx_bytes += skb->len;
>>>>  	u64_stats_update_end(&tstats->syncp);
>>>>  
>>>> +	skb_scrub_packet(skb);
>>>> +
>>>>  	if (tunnel->dev->type == ARPHRD_ETHER) {
>>>>  		skb->protocol = eth_type_trans(skb, tunnel->dev);
>>>>  		skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
>>>
>>> I can't see how this can be ok.
>>>
>>> If something in netfilter depends upon the state you are clearing out
>>> here, someone's packet filtering setup is going to break.
>>>
>>> I'm not applying these patches, sorry.
>> 
>> How can netfilter depend on the state of a packet inside of a tunnel?
>> 
>> How can it even make sense?
>> 
>> Or is your concern that we unintentionally allowed this in the past so
>> to avoid breaking binary compatibility we should continue in case
>> someone somewhere cares?
>> 
>> I really can't see how this could possibly be an intentional feature.
>
> You can make all of these issues go away by only clearing the SKB
> meta state when namespaces are actually changing as we go through
> the tunnel.

I have spent some time thinking about the cases where I have had an
opportunity to use the marks on packets and it turns out that if I had
been using a tunnel with any of those configurations leaving the marks
on would have either broken my configuration or at the very least have
required me to make certain I changed those marks.

So I really think this is a bug fix, for a long standing bug in a rare
corner case of kernel behavior that people just haven't noticed.   Which
is why I suggested to Nicolas Ditchtel that he remove the test to see if
we were changing network namespaces before scrubbing the packet.

That said I won't object if Nocolas Ditchel resends his patches with
that test put back in.  I just think it is silly and when someone
finally gets bit by the bug and complains we will have to go through and
remove the test.

Eric
