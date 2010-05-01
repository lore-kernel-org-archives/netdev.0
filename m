From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Sat, 01 May 2010 15:22:05 +0200
Message-ID: <1272720125.2230.178.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>
	 <1272547307.2222.83.camel@edumazet-laptop> <1272548258.4258.185.camel@bigi>
	 <1272548980.2222.87.camel@edumazet-laptop> <1272549408.4258.189.camel@bigi>
	 <1272573383.3969.8.camel@bigi>  <1272655814.3879.8.camel@bigi>
	 <1272660000.2230.4.camel@edumazet-laptop>  <1272672394.14499.1.camel@bigi>
	 <1272693424.2230.75.camel@edumazet-laptop> <1272713014.14499.21.camel@bigi>
	 <1272714179.2230.151.camel@edumazet-laptop>
	 <1272714966.14499.37.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:54131 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955Ab0EANWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 09:22:13 -0400
Received: by bwz19 with SMTP id 19so577485bwz.21
        for <netdev@vger.kernel.org>; Sat, 01 May 2010 06:22:11 -0700 (PDT)
In-Reply-To: <1272714966.14499.37.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 01 mai 2010 =C3=A0 07:56 -0400, jamal a =C3=A9crit :

>=20
> [1]i.e with this program rps was getting worse (it was much better
> before say net-next of apr14) and that non-rps has been getting bette=
r
> numbers since. The regression is real - but it is likely in another
> subsystem.
>=20

You must understand that the whole 'bench' is mostly governed by
scheduler artifacts. The regression you mention is probably a side
effect.

By slowing down one part, its possible to zap all calls to scheduler an=
d
go maybe 300% faster (Because consumer threads can avoid 3/4 of the tim=
e
to schedule)

Reciprocally, optimizing one part of the network stack might make
threads hitting an empty queue, and need to call more often the
scheduler.

This is why some higly specialized programs never block/schedule and
perform busy loops instead.



