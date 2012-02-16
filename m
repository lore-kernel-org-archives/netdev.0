From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Thu, 16 Feb 2012 20:44:52 +0100
Message-ID: <1329421492.2645.23.camel@edumazet-laptop>
References: <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1329400265.3048.178.camel@deadeye>
	 <1329404975.10004.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120216.120149.437368615973561397.davem@davemloft.net>
	 <CADVnQykm==YJZbdCbLxgJ236jD2yN0xT99gmeYX-FGnyBvfEGA@mail.gmail.com>
	 <1329416523.2645.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org, alekcejk@googlemail.com
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37157 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab2BPTo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 14:44:58 -0500
Received: by bkcjm19 with SMTP id jm19so2355633bkc.19
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2012 11:44:57 -0800 (PST)
In-Reply-To: <1329416523.2645.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 f=C3=A9vrier 2012 =C3=A0 19:22 +0100, Eric Dumazet a =C3=A9=
crit :

> On sender side, there are also issues, because if I have TSO on or of=
f
> on my 'netem delay 50ms' machine, performance is completely different=
=2E


Well, my sender is a 32bit kernel, so tcp_wmem[2] was less than
1Mbytes..

$ cat /proc/sys/net/ipv4/tcp_wmem
4096	16384	903780

Socket cwnd is then capped to ~400 with TSO=3Doff, and ~1500 with TSO=3D=
on


TSO off, a 1500 bytes frame now has truesize=3D2048+192, while in previ=
ous
kernel it had truesize=3D1500+192 before linux 3.2

(903780/2240 =3D 403)

(TSO permits a better truesize/len ratio, close to 1)

With 50ms RTT, 400 packets in flight means no more than 90Mbit/s
