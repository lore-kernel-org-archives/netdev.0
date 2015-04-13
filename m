From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp/dccp: get rid of central timewait timer
Date: Sun, 12 Apr 2015 18:41:13 -0700
Message-ID: <1428889273.25985.369.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428693574.25985.326.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150412.213333.176696352108729674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:32880 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143AbbDMBlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 21:41:15 -0400
Received: by iebmp1 with SMTP id mp1so54088119ieb.0
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 18:41:15 -0700 (PDT)
In-Reply-To: <20150412.213333.176696352108729674.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-04-12 at 21:33 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 10 Apr 2015 12:19:34 -0700
>=20
> > From: Eric Dumazet <edumazet@google.com>
> >=20
> > Using a timer wheel for timewait sockets was nice ~15 years ago whe=
n
> > memory was expensive and machines had a single processor.
> >=20
> > This does not scale, code is ugly and source of huge latencies
> > (Typically 30 ms have been seen, cpus spinning on death_lock spinlo=
ck.)
> >=20
> > We can afford to use an extra 64 bytes per timewait sock and spread
> > timewait load to all cpus to have better behavior.
> >=20
> > Tested:
>  ...
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>=20
> First of all, I had to munge your commit message by hand.  All of
> those ping output lines that start with '---' tell 'git am' "commit
> message ends here" so most of your test results got removed.  I added
> them back by hand.
>=20
> Second of all, this doesn't compile:
>=20
> net/ipv4/tcp_minisocks.c: In function =E2=80=98tcp_time_wait=E2=80=99=
:
> net/ipv4/tcp_minisocks.c:283:27: warning: passing argument 2 of =E2=80=
=98inet_twsk_alloc=E2=80=99 from incompatible pointer type
>   tw =3D inet_twsk_alloc(sk, &tcp_death_row.tw_count, state);
>                            ^
> In file included from include/linux/tcp.h:24:0,
>                  from include/net/tcp.h:24,
>                  from net/ipv4/tcp_minisocks.c:26:
> include/net/inet_timewait_sock.h:108:28: note: expected =E2=80=98stru=
ct inet_timewait_death_row *=E2=80=99 but argument is of type =E2=80=98=
struct atomic_t *=E2=80=99
>  struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,

Arf, I am sorry, I missed this warning, and resulting kernel was correc=
t
as tw_count was the first field of this structure.

Will send a v2.
