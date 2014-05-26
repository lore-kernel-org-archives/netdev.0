From: nickcave <nickcave.zhang@gmail.com>
Subject: Re: [PATCH] net: ipv6: Fixed up ipsec packet be re-routing issue
Date: Mon, 26 May 2014 12:38:45 +0800
Message-ID: <CAF-n9KN09vGodeE-Tb2-y+UmiqjgxfCau6h23KVir+Q6LWuZ6Q@mail.gmail.com>
References: <1400742346-24727-1-git-send-email-huizhang@marvell.com>
	<20140522.121215.16105419184813584.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: huizhang@marvell.com, netdev@vger.kernel.org,
	alan@lxorguk.ukuu.org.uk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f173.google.com ([209.85.220.173]:41022 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbaEZEiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 00:38:46 -0400
Received: by mail-vc0-f173.google.com with SMTP id il7so8578718vcb.4
        for <netdev@vger.kernel.org>; Sun, 25 May 2014 21:38:45 -0700 (PDT)
In-Reply-To: <20140522.121215.16105419184813584.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-23 0:12 GMT+08:00 David Miller <davem@davemloft.net>:
> From: huizhang <huizhang@marvell.com>
> Date: Thu, 22 May 2014 15:05:46 +0800
>
>> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
>> index 5f8e128..869b68b 100644
>> --- a/net/ipv6/xfrm6_policy.c
>> +++ b/net/ipv6/xfrm6_policy.c
>> @@ -134,6 +134,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
>>       const struct ipv6hdr *hdr = ipv6_hdr(skb);
>>       struct ipv6_opt_hdr *exthdr;
>>       const unsigned char *nh = skb_network_header(skb);
>> +     if(IP6CB(skb)->nhoff==0)
>> +             IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
>>       u8 nexthdr = nh[IP6CB(skb)->nhoff];
>>       int oif = 0;
>
> Never put actual statements in the middle of a series of variable
> declarations.
>
> Also, it would probably be better to do this assignment in
> __ip_local_out().
>
> That's the bug, we only set nhoff in the input paths, we need
> to set it in the output paths too if reaching _decode_session6
> is possible for output packets.

You are right,  __ip_local_out maybe a better place.I will submit another patch.
