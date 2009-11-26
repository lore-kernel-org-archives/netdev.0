From: Frederic Leroy <fredo@starox.org>
Subject: Re: TCP sockets stalling - help! (long)
Date: Thu, 26 Nov 2009 23:33:02 +0100
Message-ID: <20091126233302.42be8780@houba>
References: <4B0CB1B8.8030402@shiftmail.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Asdo <asdo@shiftmail.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:43556 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928AbZKZWkY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 17:40:24 -0500
In-Reply-To: <4B0CB1B8.8030402@shiftmail.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wed, 25 Nov 2009 05:25:28 +0100,
Asdo <asdo@shiftmail.org> a =C3=A9crit :

> Hi netdev and e1000 people,
>=20
> I have a weird problem here.
> [...]

I have the same kind of problem at home. I can't copy big files over
ssh unless I limit the rate ( ssh -l 8000 ... )
After reading your mail, I make some quick tests ( see below).

Results in short :
- netcat always work.
- ssh stalls, nearly immediately.

I thought fault cames from a kernel update or my wifi card update.
Apparently, I was wrong for the hardware.

Here are the test I just made :=20

network:
SG ----- eth_100_Mbps ----- ISV_BOX )))   wifi_~1.5Mb   ((( HOUBA

host HOUBA:
----
gentoo - updated frequently (once a week)
kernel vanilla : Linux houba 2.6.32-rc6-fredo4-04866-g47caac1 #5
PREEMPT Fri Nov 6 14:20:20 CET 2009 i686 Intel(R) Pentium(R) M
processor 1400MHz GenuineIntel GNU/Linux

host SG:=20
----
debian stable - not updated recently
kernel vanilla : Linux sg 2.6.32-rc5-fredo3 #2 Mon Oct 19 02:25:29 CEST
2009 i586 GNU/Linux=20
/dev/sda is a USB disk mounted on media/big

TESTS
-----

HOUBA command for tests :
netcat -l -p 2000 | pv > /dev/null

TEST1 - OK : ~5min
fredo@sg:~/remote_wake$ cat /dev/null | netcat houba 2000

TEST2 - OK : ~5min
fredo@sg:~/remote_wake$ cat /dev/sda | netcat houba 2000

TEST3 - OK :
fredo@sg:~/remote_wake$
cat /media/big/home/fredo/cdanslair/cdanslair_20091125.wmv | netcat -q
0 houba 2000

result : 291MO 0:03:32 [1,37MO/s]

TEST4 - FAILED
fredo@sg:~/remote_wake$
scp /media/big/home/fredo/cdanslair/cdanslair_20091125.wmv houba:
Stalled within seconds (5216Kb transferred) :
cdanslair_20091125.wmv          1% 5216KB   0.0KB/s - stalled -

--=20
=46r=C3=A9d=C3=A9ric Leroy
