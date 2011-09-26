From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: ECN blackhole should not force quickack mode
Date: Mon, 26 Sep 2011 10:26:54 +0200
Message-ID: <1317025614.2557.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1316757739.2560.12.camel@edumazet-laptop>
	 <1316825745.1865.24.camel@mojatatu>
	 <1316978684.2531.7.camel@edumazet-laptop>
	 <1316999266.1865.35.camel@mojatatu>  <1316999597.1865.37.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Jim Gettys <jg@freedesktop.org>,
	Dave Taht <dave.taht@gmail.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41995 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248Ab1IZI0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 04:26:45 -0400
Received: by bkbzt4 with SMTP id zt4so5527999bkb.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 01:26:43 -0700 (PDT)
In-Reply-To: <1316999597.1865.37.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 25 septembre 2011 =C3=A0 21:13 -0400, jamal a =C3=A9crit :
> On Sun, 2011-09-25 at 21:07 -0400, jamal wrote:
>=20
> > In regards to the 'linux funny extension' - this was a brilliant id=
ea
> > in my opinion back then from Alexey; lots of discussions happened b=
ut
> > I cant remember if it made it in some RFC or not (I will try to sea=
rch
> > some old archives).
>=20
> Wasnt hard:
> https://tools.ietf.org/id/draft-ietf-tsvwg-tcp-ecn-00.txt
> It doesnt seem to have made it to RFC and i cant remember why.
> [We dont wanna bring Sally out of retirement but we can ask KK if
> it bugs you;->]

Thanks !

This refers to additions to RFC 2481 : This was refined by RFC 3168, an=
d
the retransmitted TCP packets requirement is part of the final RFC :

6.1.5.  Retransmitted TCP packets

   This document specifies ECN-capable TCP implementations MUST NOT set
   either ECT codepoint (ECT(0) or ECT(1)) in the IP header for
   retransmitted data packets, ...

=46ollowed by a very long description :)

BTW, the ECN+ proposal (RFC 5562 :  Adding Explicit Congestion
Notification (ECN) Capability to TCP's SYN/ACK Packets) would allow the
client (receiving SYNACK message with ECT flags) to set the TCP_ECN_SEE=
N
I added in my patch, allowing even the first (retransmitted) data packe=
t
to trigger quickack mode.
