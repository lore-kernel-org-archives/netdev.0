From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Very low latency TCP for clusters
Date: Tue, 20 Jul 2010 00:03:00 +0200
Message-ID: <1279576980.2458.56.camel@edumazet-laptop>
References: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
	 <1279561319.2553.153.camel@edumazet-laptop>
	 <AANLkTiniRmnwG4vT-MrQQHQjrdQ4sfOn6Uxi42Dsr8nu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47342 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965985Ab0GSWDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 18:03:06 -0400
Received: by wwb39 with SMTP id 39so676094wwb.1
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 15:03:03 -0700 (PDT)
In-Reply-To: <AANLkTiniRmnwG4vT-MrQQHQjrdQ4sfOn6Uxi42Dsr8nu@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 juillet 2010 =C3=A0 11:44 -0700, Tom Herbert a =C3=A9crit :

> I see about 7 usecs as best number on loopback, so I believe this is
> in the ballpark.  As I mentioned above, this about "best case" latenc=
y
> of a single thread, so we assume any amount of pinning or other
> customized configuration to that purpose.

Well, given I get 29 us on a ping between two machines (Gb link, no
process involved on receiver, only softirq), I really doubt we can reac=
h
5 us on a tcp test involving a user process on both side ;)

$ ping -f -c 10000 -q 192.168.0.1
PING 192.168.0.1 (192.168.0.1) 56(84) bytes of data.

--- 192.168.0.1 ping statistics ---
10000 packets transmitted, 10000 received, 0% packet loss, time 395ms
rtt min/avg/max/mdev =3D 0.029/0.032/0.434/0.010 ms, ipg/ewma 0.039/0.0=
33
ms


On loopback, its a bit better of course, but there is no cache miss nor
scheduler involved.

$ ping -f -c 10000 -q 127.0.0.1
PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.

--- 127.0.0.1 ping statistics ---
10000 packets transmitted, 10000 received, 0% packet loss, time 55ms
rtt min/avg/max/mdev =3D 0.002/0.002/0.015/0.001 ms, ipg/ewma 0.005/0.0=
02
ms


