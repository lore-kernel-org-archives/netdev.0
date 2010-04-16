From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 20:53:13 +0200
Message-ID: <1271443994.16881.4249.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
	 <20100415.233334.242114544.davem@davemloft.net>
	 <1271401007.16881.3762.camel@edumazet-laptop>
	 <l2m65634d661004161135h1c1466afi54787022bfc2ce12@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:47101 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093Ab0DPSxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 14:53:18 -0400
Received: by bwz25 with SMTP id 25so3504589bwz.28
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 11:53:16 -0700 (PDT)
In-Reply-To: <l2m65634d661004161135h1c1466afi54787022bfc2ce12@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 avril 2010 =C3=A0 11:35 -0700, Tom Herbert a =C3=A9crit =
:
> Results with "tbench 16" on an 8 core Intel machine.
>=20
> No RPS/RFS:  2155 MB/sec
> RPS (0ff mask): 1700 MB/sec
> RFS: 1097
>=20
> I am not particularly surprised by the results, using loopback
> interface already provides good parallelism and RPS/RFS really would
> only add overhead and more trips between CPUs (last part is why RPS <
> RFS I suspect)-- I guess this is why we've never enabled RPS on
> loopback :-)
>=20
> Eric, do you have a particular concern that this could affect a real =
workload?
>=20

I was expecting RFS to be better than RPS at least, for this particular
workload (tcp over loopback)

With RPS, the hash function of (127.0.0.1, port1, 127.0.0.1, port2)
is different than (127.0.0.1, port2, 127.0.0.1, port1), so basically we
force the server to run on different processor than client

However, I was expecting that with RFS, client and server would run on
same cpu.

Maybe we could change (for a test) hash function to use  (sport ^ dport=
)
instead of (sport << 16) + dport=20



