From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Small problem with tcp_poll and RST
Date: Wed, 15 Sep 2010 22:41:47 +0200
Message-ID: <1284583307.2462.29.camel@edumazet-laptop>
References: <AANLkTik-FQ7aF0Cp0NicERYLG1vFG4SAe4aeeMHzxNhO@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tom Marshall <tdm.code@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52128 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281Ab0IOUlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 16:41:52 -0400
Received: by wyf22 with SMTP id 22so655777wyf.19
        for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 13:41:51 -0700 (PDT)
In-Reply-To: <AANLkTik-FQ7aF0Cp0NicERYLG1vFG4SAe4aeeMHzxNhO@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 septembre 2010 =C3=A0 13:17 -0700, Tom Marshall a =C3=A9=
crit :
> The code in tcp_poll seems to suffer from a race condition which can
> result in POLLIN but not POLLOUT for an outbound socket connection to
> a closed peer.
>=20
> This can happen if, for example, the RST comes in immediately after
> checking sk->sk_err.  It is a small window of opportunity and so it
> only happens rarely.
>=20
> Note this code has remained pretty much unchanged in 2.6.x for years,
> and the problem readily reproduces on a wide variety of systems (RHEL
> 5.x, Ubuntu 10.04, etc.)
>=20
> I suppose it is arguable whether this is a bug or whether it deserves
> to be fixed, but it did cause an issue with some (admittedly broken)
> userspace code at my company.
>=20
> I do not fully understand the intricacies of the interactions between
> the TCP state machine and the tcp_poll function (which runs unlocked)=
=2E
>  However, I did find that the below appears to fix the issue.  Since
> the overhead is minimal when the socket state does not change, it
> should have very little performance impact.
>=20
>         unsigned char oldstate;
> again:
>         oldstate =3D sk->sk_state;
>=20
>         /* body of tcp_poll */
>=20
>         if (sk->sk_state !=3D oldstate)
>                 goto again;
>=20

Hi Tom

Unfortunately this might shorten the race window.

Are you saying an application is blocked on a poll(events=3DPOLLOUT) ?

If yes, we have a bug elsewhere (in RST processing)



