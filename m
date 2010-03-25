From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] RPS: support 802.1q and pppoe session
Date: Thu, 25 Mar 2010 06:58:25 +0100
Message-ID: <1269496705.15280.89.camel@edumazet-laptop>
References: <4BAAE6E9.6030103@gmail.com>
	 <1269493402.15280.29.camel@edumazet-laptop>
	 <412e6f7f1003242212t242a30e0k635bdfb861c324e4@mail.gmail.com>
	 <1269494668.15280.72.camel@edumazet-laptop>
	 <412e6f7f1003242247h79dd3ce0u449a1e71bf4ec742@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:61360 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab0CYF63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 01:58:29 -0400
Received: by bwz1 with SMTP id 1so555616bwz.21
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 22:58:28 -0700 (PDT)
In-Reply-To: <412e6f7f1003242247h79dd3ce0u449a1e71bf4ec742@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 mars 2010 =C3=A0 13:47 +0800, Changli Gao a =C3=A9crit :

> Yea, we do DPI in netfilter. And for a stateful fireware, connection
> tracking isn't cheap. As bandwidth increases, we find one CPU can't
> handle all the traffic from a single NIC. We currently use dynamic
> weighted packets distributing algorithm with patched Linux-2.6.18, an=
d
> it works very well.
>=20

Hmm... we added RCU to conntrack last year only, so with 2.6.18
conntrack hits a global lock.

tcp conntrack also uses another global lock, this is not yet converted,
even in 2.6.33.
How can this scale ?


> Oh, maybe I misunderstood you words. I thought the rxhash you want to
> clear is computed by get_rps_cpu()? I remembered some NIC itself can
> get 5-tuple from vlan and pppoe packets to compute hash. In that case=
,
> we should not clear rxhash.
>=20

rxhash is provided/computed only if its possible, and stay 0 if its not
possible to compute it :)

AFAIK, at this point, no network driver currently provides a rxhash. If
you know some NIC can provide it, please submit a patch :)



