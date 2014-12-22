From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: Regression with commit 971f10eca186 ("tcp: better TCP_SKB_CB
 layout to reduce cache line misses")
Date: Mon, 22 Dec 2014 17:54:19 +0100
Message-ID: <54984CBB.6090605@6wind.com>
References: <54983612.8000600@6wind.com> <1419264939.11185.18.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:53520 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754799AbaLVQyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 11:54:22 -0500
Received: by mail-wi0-f178.google.com with SMTP id em10so8466245wid.17
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 08:54:20 -0800 (PST)
In-Reply-To: <1419264939.11185.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/12/2014 17:15, Eric Dumazet a =C3=A9crit :
> On Mon, 2014-12-22 at 16:17 +0100, Nicolas Dichtel wrote:
>> One of our engineer (Huaibin Wang <huaibin.wang@6wind.com>) has repo=
rted and
>> analysed this bug:
>>
>> This commit introduces a regression with IPv6 + IPsec transport + TC=
P.
>>
>> In TCP (net/ipv6/tcp_ipv6.c), xfrm6_policy_check() is called and thu=
s, after
>> some intermediate functions, _decode_session6() is also called.
>>
>> This function uses IP6CB() (u8 nexthdr =3D nh[IP6CB(skb)->nhoff]), w=
hich is wrong
>> becauses it has been moved to the end of TCP_SKB_CB().
>>
>> Not sure what is the best way to fix this, any suggestion?
>
> Thanks for the report
>
> Presumably tcp_v6_rcv() needs to be reordered so that
> xfrm6_policy_check() calls are done before the CB swap.
>
> swap should probably be done right before bh_lock_sock_nested()
>
> I am currently traveling and I am not sure if I can get Internet acce=
ss
> to post a patch soon.
Ok, thank you for the tip. I will try to cook a patch.
