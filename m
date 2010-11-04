From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net dst: fix percpu_counter list corruption and poison
 overwritten
Date: Wed, 03 Nov 2010 18:59:14 -0700 (PDT)
Message-ID: <20101103.185914.245411332.davem@davemloft.net>
References: <1288750265-17664-1-git-send-email-dfeng@redhat.com>
	<1288761773.2467.535.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dfeng@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37031
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754629Ab0KDB6u convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Nov 2010 21:58:50 -0400
In-Reply-To: <1288761773.2467.535.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 03 Nov 2010 06:22:53 +0100

> Le mercredi 03 novembre 2010 =E0 10:11 +0800, Xiaotian Feng a =E9crit=
 :
>> There're some percpu_counter list corruption and poison overwritten =
warnings
>> in recent kernel, which is resulted by fc66f95c.
>>=20
>> commit fc66f95c switches to use percpu_counter, in ip6_route_net_ini=
t, kernel
>> init the percpu_counter for dst entries, but, the percpu_counter is =
never destroyed
>> in ip6_route_net_exit. So if the related data is freed by kernel, th=
e freed percpu_counter
>> is still on the list, then if we insert/remove other percpu_counter,=
 list corruption
>> resulted. Also, if the insert/remove option modifies the ->prev,->ne=
xt pointer of
>> the freed value, the poison overwritten is resulted then.
>>=20
>> With the following patch, the percpu_counter list corruption and poi=
son overwritten
>> warnings disappeared.
>>=20
>> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
 ...
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks!
