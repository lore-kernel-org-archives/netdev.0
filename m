From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need
 also be handled by UFO
Date: Wed, 2 Oct 2013 14:10:39 +0200
Message-ID: <20131002121039.GD1528@minipsycho.brq.redhat.com>
References: <20130921042700.GB8070@order.stressinduktion.org>
 <20130930114343.GA6356@minipsycho.brq.redhat.com>
 <20130930172312.GE10771@order.stressinduktion.org>
 <20131001105837.GA1424@minipsycho.brq.redhat.com>
 <20131001120907.GH10771@order.stressinduktion.org>
 <20131001123214.GI10771@order.stressinduktion.org>
 <20131001214721.GJ10771@order.stressinduktion.org>
 <20131001232534.GM10771@order.stressinduktion.org>
 <20131002112052.GC1528@minipsycho.brq.redhat.com>
 <1380714835.19002.92.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, herbert@gondor.apana.org.au,
	hannes@stressinduktion.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:47157 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844Ab3JBMKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 08:10:43 -0400
Received: by mail-we0-f172.google.com with SMTP id w61so821928wes.31
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 05:10:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1380714835.19002.92.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 02, 2013 at 01:53:55PM CEST, eric.dumazet@gmail.com wrote:
>
>> This patch should fix this on ipv4 as well:
>> 
>> Subject: ip_output: do skb ufo init for peeked non ufo skb as well
>> 
>
>Is it an official patch ? s/Subject:/[PATCH]/ 

Yes. I thought that to state "Subject:" is enough for patchwork to parse
it. Apparently not :/

>
>> Now, if user application does:
>
>Any idea when the bug was added (commit id + title) ?

This is hard to say. This code is more or less broken from the very
beginning, which is:

commit e89e9cf539a28df7d0eb1d0a545368e9920b34ac "[IPv4/IPv6]: UFO Scatter-gather approach"

>
>> sendto len<mtu flag MSG_MORE
>> sendto len>mtu flag 0
>> The skb is not treated as fragmented one because it is not initialized
>> that way. So move the initialization to fix this.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  net/ipv4/ip_output.c | 14 +++++++++-----
>>  1 file changed, 9 insertions(+), 5 deletions(-)
>> 
>> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
>> index a04d872..bd21c5d 100644
>> --- a/net/ipv4/ip_output.c
>> +++ b/net/ipv4/ip_output.c
>> @@ -772,15 +772,19 @@ static inline int ip_ufo_append_data(struct sock *sk,
>>  		/* initialize protocol header pointer */
>>  		skb->transport_header = skb->network_header + fragheaderlen;
>>  
>> -		skb->ip_summed = CHECKSUM_PARTIAL;
>>  		skb->csum = 0;
>
>Any idea why we have skb->csum = 0 here ?

If I understand this correctly, that can be removed from here.


>
>Thanks !
>
>
