From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: minor: tcp: use tcp_skb_mss helper in tcp_tso_segment
Date: Fri, 07 Jun 2013 07:43:18 +0200
Message-ID: <51B172F6.7050807@redhat.com>
References: <1370563643-19556-1-git-send-email-dborkman@redhat.com> <1370568043.24311.406.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29562 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750812Ab3FGFnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jun 2013 01:43:25 -0400
In-Reply-To: <1370568043.24311.406.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2013 03:20 AM, Eric Dumazet wrote:
> On Fri, 2013-06-07 at 02:07 +0200, Daniel Borkmann wrote:
>> We have the minimal inline helper tcp_skb_mss to access
>> skb_shinfo(skb)->gso_size, so also use it here to get mss.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   net/ipv4/tcp.c | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
>> index b5d4ad9..6a1cf95 100644
>> --- a/net/ipv4/tcp.c
>> +++ b/net/ipv4/tcp.c
>> @@ -2905,7 +2905,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
>>   	oldlen = (u16)~skb->len;
>>   	__skb_pull(skb, thlen);
>>
>> -	mss = skb_shinfo(skb)->gso_size;
>> +	mss = tcp_skb_mss(skb);
>
> Conceptually, this is part of the GRO/GSO layer.
>
> It would be nice to move this stuff in net/ipv4/tcp_offload.c
> to makes things explicit.

Agreed, will do.
