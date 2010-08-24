From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: use skb_get_rxhash()
Date: Tue, 24 Aug 2010 22:35:35 +0800
Message-ID: <AANLkTinBtShO+upVVmKvuqYL1shfBusNLG343EVmmYQT@mail.gmail.com>
References: <1282643558-20866-1-git-send-email-xiaosuo@gmail.com>
 <1282645262.2477.64.camel@edumazet-laptop> <AANLkTi=AkO0hUZ7o3uwX5zrxeiLi1TsLzu5QL=pUrAju@mail.gmail.com>
 <1282658991.2477.233.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42089 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094Ab0HXOf4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 10:35:56 -0400
Received: by wyb35 with SMTP id 35so536334wyb.19
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 07:35:55 -0700 (PDT)
In-Reply-To: <1282658991.2477.233.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 24, 2010 at 10:09 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mardi 24 ao=FBt 2010 =E0 21:53 +0800, Changli Gao a =E9crit :
>
>> However, do we really need to check if skb->sk->sk_hash is zero? It =
is
>> a rare case, and this check may mislead someone to think a non zero
>> sk_hash means that sk_hash is set.
>>
>
> Not sure what you mean ;)
>
> sk_hash is not always filled, only for some kind of sockets (tcp, udp=
)
>

Hmm, if so, I think maybe addr_fold(skb->sk) is enough and more common.

if (skb->sk)
   hash =3D addr_fold(skb->sk);
else
   hash =3D skb->rxhash; /* saved addr_fold(skb->sk) by skb_orphan_try(=
)
previous */

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
