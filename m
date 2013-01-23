From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unix Socket buffer attribution
Date: Wed, 23 Jan 2013 08:56:28 -0800
Message-ID: <1358960188.12374.830.camel@edumazet-glaptop>
References: <CAJ4BwwFZo=ktoNBpw14yxyvR1QPQ_xVzKRs=R7qv03g1uwn8pg@mail.gmail.com>
	 <kdoibl$978$1@ger.gmane.org> <1358951180.12374.787.camel@edumazet-glaptop>
	 <CAJ4BwwG-fimMeSD_DSNZZz=Vjz3Qk_58qEnMGv_gmn0rTSeZAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Yannick Koehler <yannick@koehler.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:37363 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754864Ab3AWQ4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 11:56:32 -0500
Received: by mail-pb0-f42.google.com with SMTP id rp2so4800407pbb.15
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 08:56:31 -0800 (PST)
In-Reply-To: <CAJ4BwwG-fimMeSD_DSNZZz=Vjz3Qk_58qEnMGv_gmn0rTSeZAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 11:36 -0500, Yannick Koehler wrote:
> > So what prevents a malicious program to DOS the machine ?
>=20
> The recv queue (checked with recvq_full()) and receiving's socket
> rcvbuf (check added in my patch).
>=20

Nope. The limit is given in number of messages, and its the socket
backlog. Many machines setup a somaxconn =3D 1024 limit in order
to reasonably listen for TCP connections.

> Actually the current situation can easily lead to a DOS situation.  I
> simply have to write one application that connect to a unix socket
> domain and have it send me data for which I never call recvfrom() and
> voil=C3=A0, all other consumer of this unix socket application will n=
o more
> be able to communicate with this application once it maxed out it's
> sndbuf, default is 128k I believe.

A single message can consume ~128k.

If we allow 1024 messages being sent, we consume 128 Mbytes per evil
socket.

Enough to kill many linux based devices.

You'll have to add proper limits (SO_RCVBUF), accounting the truesize o=
f
all accumulated messages.
