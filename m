From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: synchronize bind() with RTM_NEWADDR notifications
Date: Thu, 21 Oct 2010 13:12:57 +0200
Message-ID: <1287659577.6871.69.camel@edumazet-laptop>
References: <1287655930-16879-1-git-send-email-timo.teras@iki.fi>
	 <1287656753.6871.46.camel@edumazet-laptop>	<4CC018E1.3000906@iki.fi>
	 <20101021.035004.212683583.davem@davemloft.net>  <4CC01CC0.7090101@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53156 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756551Ab0JULND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:13:03 -0400
Received: by wwf26 with SMTP id 26so2421015wwf.1
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 04:13:01 -0700 (PDT)
In-Reply-To: <4CC01CC0.7090101@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 21 octobre 2010 =C3=A0 13:58 +0300, Timo Ter=C3=A4s a =C3=A9cr=
it :
> On 10/21/2010 01:50 PM, David Miller wrote:
> > From: Timo Ter=C3=A4s <timo.teras@iki.fi>
> > Date: Thu, 21 Oct 2010 13:41:37 +0300
> >=20
> >> Is inet_bind() called from non-userland context? If yes, then this=
 is a
> >> bad idea. Otherwise I don't think it's that hot path...
> >=20
> > It is.
>=20
> Yet, almost immediately after that there is lock_sock() which can als=
o
> sleep. How does that work then?
>=20

I am not sure I understand your question. Maybe my answer wont be clear=
=2E

rtnl_lock() can take ages on some setups, because its using one single
and shared mutex. Its use should be restricted to administrative
purposes.

bind() is a pretty hot path on many workloads, this is hardly what we
call an administrative task.

lock_sock() uses a per socket lock, and it is a _bit_ more scalable, yo=
u
can have 4096 cpus all using bind()/recv()/send()/... at the same time,
it just works.



