From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] RPS: support 802.1q and pppoe session
Date: Thu, 25 Mar 2010 14:09:40 +0800
Message-ID: <412e6f7f1003242309u1c65f418lee8e9fc56a4bb5f9@mail.gmail.com>
References: <4BAAE6E9.6030103@gmail.com> <1269493402.15280.29.camel@edumazet-laptop>
	<412e6f7f1003242212t242a30e0k635bdfb861c324e4@mail.gmail.com>
	<1269494668.15280.72.camel@edumazet-laptop> <412e6f7f1003242247h79dd3ce0u449a1e71bf4ec742@mail.gmail.com>
	<1269496705.15280.89.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:33665 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160Ab0CYGKD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 02:10:03 -0400
Received: by iwn6 with SMTP id 6so3381296iwn.4
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 23:10:01 -0700 (PDT)
In-Reply-To: <1269496705.15280.89.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 25, 2010 at 1:58 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 25 mars 2010 =C3=A0 13:47 +0800, Changli Gao a =C3=A9crit :
>
>
> Hmm... we added RCU to conntrack last year only, so with 2.6.18
> conntrack hits a global lock.
>
> tcp conntrack also uses another global lock, this is not yet converte=
d,
> even in 2.6.33.
> How can this scale ?
>

In our case, conntrack isn't a big issue, but DPI is. So we use per
connrack lock other than the global conntrack lock, and distributing
the two sides traffic belongs to the same conntrack to the same CPU,
so in normal case, there isn't any lock contention.

>
> rxhash is provided/computed only if its possible, and stay 0 if its n=
ot
> possible to compute it :)
>
> AFAIK, at this point, no network driver currently provides a rxhash. =
If
> you know some NIC can provide it, please submit a patch :)
>

It is a part of a private NP, and its code isn't in mainline. :(

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
