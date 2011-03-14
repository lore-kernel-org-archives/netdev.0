From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 2/2] dev : fix mtu check when TSO is enabled
Date: Mon, 14 Mar 2011 20:00:43 +0100
Message-ID: <4D7E65DB.8070708@free.fr>
References: <1300118888-2311-1-git-send-email-daniel.lezcano@free.fr>	 <1300118888-2311-2-git-send-email-daniel.lezcano@free.fr> <1300122105.3423.131.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kaber@trash.net, nightnord@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:53623 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751976Ab1CNTA7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 15:00:59 -0400
In-Reply-To: <1300122105.3423.131.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/2011 06:01 PM, Eric Dumazet wrote:
> Le lundi 14 mars 2011 =C3=A0 17:08 +0100, Daniel Lezcano a =C3=A9crit=
 :
>> In case the device where is coming from the packet has TSO enabled,
>> we should not check the mtu size value as this one could be bigger
>> than the expected value.
>>
>> This is the case for the macvlan driver when the lower device has
>> TSO enabled. The macvlan inherit this feature and forward the packet=
s
>> without fragmenting them. Then the packets go through dev_forward_sk=
b
>> and are dropped. This patch fix this by checking TSO is not enabled
>> when we want to check the mtu size.
>>
>> Signed-off-by: Daniel Lezcano<daniel.lezcano@free.fr>
>> Cc: Patrick McHardy<kaber@trash.net>
>> Cc: Andrian Nord<nightnord@gmail.com>
>> ---
>>   net/core/dev.c |    6 ++++--
>>   1 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 6561021..010a0a9 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1526,8 +1526,10 @@ int dev_forward_skb(struct net_device *dev, s=
truct sk_buff *skb)
>>   	skb_orphan(skb);
>>   	nf_reset(skb);
>>
>> -	if (unlikely(!(dev->flags&  IFF_UP) ||
>> -		     (skb->len>  (dev->mtu + dev->hard_header_len + VLAN_HLEN))))=
 {
>> +	if (unlikely(!(skb->dev->features&  NETIF_F_TSO)&&
>
> Sorry, this needs a comment at least, or even better a helper functio=
n
> on its own.
>
> We test both skb->dev&  dev, pointing to different devices, this is
> really error prone.
>
> Are we sure all callers set skb->dev before calling  dev_forward_skb(=
) ?

Thanks Eric for the comments, I will resend a new version.

   -- Daniel

