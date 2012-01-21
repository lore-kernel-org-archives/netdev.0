From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Query regarding a code snippet in __inet_lookup_established.
Date: Sat, 21 Jan 2012 08:30:25 +0100
Message-ID: <1327131025.6338.1.camel@edumazet-laptop>
References: <CAP3iWTRS5d5dHLFpkOmiTuh46pPnFLLiJ1FG=WTumt-1B8DgZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: MuraliRaja Muniraju <muralira@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:35991 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566Ab2AUHaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2012 02:30:30 -0500
Received: by wics10 with SMTP id s10so997892wic.19
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2012 23:30:28 -0800 (PST)
In-Reply-To: <CAP3iWTRS5d5dHLFpkOmiTuh46pPnFLLiJ1FG=WTumt-1B8DgZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 20 janvier 2012 =C3=A0 17:02 -0800, MuraliRaja Muniraju a =C3=
=A9crit :
> Hi All,
>     In function __inet_lookup_established, I do see a potential issue
> in a corner case while reading through the code where socket can be
> freed while being in the list and also while in rcu_read critical
> section.
>         rcu_read_lock();
> begin:
>         sk_nulls_for_each_rcu(sk, node, &head->chain) {
>                 if (INET_MATCH(sk, net, hash, acookie,
>                                         saddr, daddr, ports, dif)) {
>                         if (unlikely(!atomic_inc_not_zero(&sk->sk_ref=
cnt)))
>                                 goto begintw;
>                         if (unlikely(!INET_MATCH(sk, net, hash, acook=
ie,
>                                 saddr, daddr, ports, dif))) {
> Murali>                                sock_put(sk);
> Murali>                                goto begin;
>                         }
>                         goto out;
>                 }
>         }
>=20
> I am not certain under what scenario this might occur. Can someone le=
t
> me know if this is a possibility.

Since we succeeded in atomic_inc_not_zero(&sk->sk_refcnt), socket canno=
t
be freed until our sock_put()
