From: Vincent Pelletier <plr.vincent@gmail.com>
Subject: Re: r8169: IO_PAGE_FAULT & netdev watchdog
Date: Sat, 2 Jun 2012 15:42:28 +0200
Message-ID: <201206021542.28869.plr.vincent@gmail.com>
References: <201205312331.06623.plr.vincent@gmail.com> <201206021108.53551.plr.vincent@gmail.com> <20120602105645.GA28769@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:45157 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759650Ab2FBNmf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 09:42:35 -0400
Received: by wgbdr13 with SMTP id dr13so2736197wgb.1
        for <netdev@vger.kernel.org>; Sat, 02 Jun 2012 06:42:33 -0700 (PDT)
In-Reply-To: <20120602105645.GA28769@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 02 juin 2012 12:56:45, vous avez =E9crit :
> And partly because the patch I sent included its content in the commi=
t
> message as well. :o/

I noticed the repetition after trying to apply on 3.4, and dropped one.=
 And=20
only then realised it was really already applied.

> If the inlined patch makes a difference, you should see it with 3.4.

It made a difference, when testing with netcat: without any change over=
=20
vanilla 3.3.7, network trafic drops to 0 in a matter of seconds (up to =
around=20
10s). With it, it stayed stable for 10 minutes, until I killed nc.
I reproduced this with 3.4 as well (no patch =3D bug, patch =3D no prob=
lem).
In both version without patch, I got the watchdog warning 10 minutes af=
ter=20
traffic drop - though without the IO_PAGE_FAULT message.

I spent quite some time testing with nc in UDP mode first, and couldn't=
=20
reproduce the issue (then I switched to TCP as said above). Does that m=
ake any=20
sense ?
I also noticed the significant lag at bootup when eth0 is brought up is=
 much=20
reduced on patched kernel. Does that makes sense ?

=46WIW, the commands I used were based on:
  nc -l -p 5555 < /dev/zero > /dev/null

With/without -u flag, and of course client-side equivalent command so t=
he=20
connection was used full-duplex at maximum speed: 450Mb/s in TCP, 800+M=
b/s in=20
UDP, each way. UDP was limited by CPU on one side (~450Mb/s upload from=
=20
that box, 800Mb/s download, 100% cpu on it).
Values are as reported by nload & htop.
All tests were done in runlevel 2, with rsyslog manually started with i=
ts init=20
script.

> My life is a bit easier when you work somewhere in the main branch
> (or in davem's -next but it is not relevant for regression fixes).

I'm not sure: does 3.4 tarball from kernel.org qualify as "main branch"=
 ?=20
Otherwise, which git repos & branch should I use ?

Regards,
--=20
Vincent Pelletier
