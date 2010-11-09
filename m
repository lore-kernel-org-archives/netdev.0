From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Tue, 09 Nov 2010 15:25:42 +0100
Message-ID: <1289312742.18992.21.camel@edumazet-laptop>
References: <1288954189.28003.178.camel@firesoul.comx.local>
	 <1288988955.2665.297.camel@edumazet-laptop>
	 <1289213926.15004.19.camel@firesoul.comx.local>
	 <1289214289.2820.188.camel@edumazet-laptop>
	 <1289228785.2820.203.camel@edumazet-laptop>
	 <1289311159.17448.9.camel@traveldev.cxnet.dk>
	 <1289312178.17448.20.camel@traveldev.cxnet.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:59181 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439Ab0KIOZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 09:25:56 -0500
Received: by ewy7 with SMTP id 7so3547671ewy.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 06:25:54 -0800 (PST)
In-Reply-To: <1289312178.17448.20.camel@traveldev.cxnet.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 novembre 2010 =C3=A0 15:16 +0100, Jesper Dangaard Brouer a
=C3=A9crit :
> On Tue, 2010-11-09 at 14:59 +0100, Jesper Dangaard Brouer wrote:
> > On Mon, 2010-11-08 at 16:06 +0100, Eric Dumazet wrote:
> > ...
> > > > > > > I noticed that the loopback performance has gotten quite =
bad:
> > > > > > >=20
> > > > > > > http://www.phoronix.com/scan.php?page=3Darticle&item=3Dli=
nux_2612_2637&num=3D6
>=20
> > > Their network test is basically :
> > >=20
> > > netcat -l 9999 >/dev/null &
> > > time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat  127.0.0.1 =
9999
> >=20
> > Should it not be:
> >  netcat -l -p 9999 >/dev/null &
> >=20
> > When I run the commands "dd | netcat", netcat never finish/exits, I=
 have
> > to press Ctrl-C to stop it.  What am I doing wrong? Any tricks?
>=20
> To fix this I added "-q 0" to netcat.  Thus my working commands are:
>=20
>  netcat -l -p 9999 >/dev/null &
>  time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat -q0 127.0.0.1 =
9999
>=20
> Running this on my "big" 10G testlab system, Dual Xeon 5550 2.67GHz,
> kernel version 2.6.32-5-amd64 (which I usually don't use)
> The results are 7.487 sec:
>=20
> time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat -q0 127.0.0.1 9=
999
> 10000+0 records in
> 10000+0 records out
> 10485760000 bytes (10 GB) copied, 7,48562 s, 1,4 GB/s
>=20
> real    0m7.487s
> user    0m0.224s
> sys     0m9.785s

So far, so good. These are the expected numbers. Now we have to
understand why corei7 gets 38 seconds instead of 8 :)



