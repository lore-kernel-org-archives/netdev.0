From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Tue, 09 Nov 2010 15:06:12 +0100
Message-ID: <1289311573.18992.1.camel@edumazet-laptop>
References: <1288954189.28003.178.camel@firesoul.comx.local>
	 <1288988955.2665.297.camel@edumazet-laptop>
	 <1289213926.15004.19.camel@firesoul.comx.local>
	 <1289214289.2820.188.camel@edumazet-laptop>
	 <1289228785.2820.203.camel@edumazet-laptop>
	 <1289311159.17448.9.camel@traveldev.cxnet.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64255 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649Ab0KIOG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 09:06:27 -0500
Received: by wwb39 with SMTP id 39so19065wwb.1
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 06:06:26 -0800 (PST)
In-Reply-To: <1289311159.17448.9.camel@traveldev.cxnet.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 novembre 2010 =C3=A0 14:59 +0100, Jesper Dangaard Brouer a
=C3=A9crit :
> On Mon, 2010-11-08 at 16:06 +0100, Eric Dumazet wrote:
> ...
> > > > > > I noticed that the loopback performance has gotten quite ba=
d:
> > > > > >=20
> > > > > > http://www.phoronix.com/scan.php?page=3Darticle&item=3Dlinu=
x_2612_2637&num=3D6
> > >
>=20
> > CC netdev, if you dont mind.
>=20
> No problem :-)
>=20
> > Their network test is basically :
> >=20
> > netcat -l 9999 >/dev/null &
> > time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat  127.0.0.1 99=
99
>=20
> Should it not be:
>  netcat -l -p 9999 >/dev/null &
>=20

It depends on netcat version. On yours, yes, you need the "-p"

> When I run the commands "dd | netcat", netcat never finish/exits, I h=
ave
> to press Ctrl-C to stop it.  What am I doing wrong? Any tricks?
>=20
> "dd" reports 17.54 sec, and but the "time" measurement cannot be uses=
 as
> the netcat just hangs/waits for more data...
>=20

Your netcat version needs a "-c" switch

time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat -c 127.0.0.1 9999


> time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat 127.0.0.1 9999
> 10000+0 records in
> 10000+0 records out
> 10485760000 bytes (10 GB) copied, 17,5419 s, 598 MB/s
>=20
> When I run the commands, I see 261682 context switches per sec...
>=20
> This quick test were on a Core i7 920 using kernel
> 2.6.32-rc3-net-next-dev-mp2t.
>=20

32 or 64bit kernel ?

Thanks !



