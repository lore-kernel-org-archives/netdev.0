From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Thu, 16 Feb 2012 19:22:03 +0100
Message-ID: <1329416523.2645.7.camel@edumazet-laptop>
References: <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1329400265.3048.178.camel@deadeye>
	 <1329404975.10004.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120216.120149.437368615973561397.davem@davemloft.net>
	 <CADVnQykm==YJZbdCbLxgJ236jD2yN0xT99gmeYX-FGnyBvfEGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org, alekcejk@googlemail.com
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64638 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312Ab2BPSWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 13:22:08 -0500
Received: by bkcjm19 with SMTP id jm19so2252661bkc.19
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2012 10:22:07 -0800 (PST)
In-Reply-To: <CADVnQykm==YJZbdCbLxgJ236jD2yN0xT99gmeYX-FGnyBvfEGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 f=C3=A9vrier 2012 =C3=A0 12:22 -0500, Neal Cardwell a =C3=A9=
crit :
> Our team has also run into issues with GRO/LRO "stretch ACKs", and
> their negative impact on TCP performance. We have a patch that we've
> been working with that deals with the sender-side issues. It turns ou=
t
> that neither the ABC nor non-ABC byte counting quite fixes the stretc=
h
> ACKs issues.
>=20
> On the receiver side, the approach of changing tcp_grow_window() and
> __tcp_grow_window() to adjust things in terms of actual packet size
> rather than a fixed 2*MSS sounds great to me as well.
>=20
> In terms of the original 3.1 vs 3.2 issue report that started this
> thread, I didn't see any evidence of LRO or GRO causing stretch ACKs.
> (Alexey, would you be able to confim by running "ethtool -k eth0" on
> both kernels?) So it seems that probably the original issue is
> unrelated to stretch ACKs?
>=20

I do believe the "3.1 vs 3.2" issue is a matter of how skb truesize
fixes uncover prior bugs in tcp stack. Some drivers were lying about sk=
b
truesize in hope to avoid these bugs...

=46or instance, I think we dont open receiver window fast enough in thi=
s
case, (and we probably enter the slow __tcp_grow_window() path)

On sender side, there are also issues, because if I have TSO on or off
on my 'netem delay 50ms' machine, performance is completely different.

It might have something to do with BQL. More testings needed.
