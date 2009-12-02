From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: scp stalls mysteriously
Date: Wed, 02 Dec 2009 20:17:44 +0100
Message-ID: <4B16BD58.3040802@tvk.rwth-aachen.de>
References: <20091128010156.1219012a@houba>
 <alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi>
 <20091130195004.38dbc319@houba>
 <alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi>
 <20091130213727.2f4047d2@houba>
 <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
 <20091201211945.505d3c98@houba>
 <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
 <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
 <20091202154403.GB30730@sd-11162.dedibox.fr>
 <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
 <20091202183451.173db5f2@houba>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:42368 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755345AbZLBTRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 14:17:39 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KU1003A6HLLU5C0@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 02 Dec 2009 20:17:45 +0100 (CET)
In-reply-to: <20091202183451.173db5f2@houba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rederic Leroy schrieb:
> Le Wed, 2 Dec 2009 18:05:24 +0200 (EET),
> "Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :
>=20
>>>> In one of the cases, also the sg end dies (the 4th case). I
>>>> suppose that was running earlier kernel already?
>>> This case was the one with tcp_frto=3D2 and tcp_timestamps=3D0 on h=
ouba.
>> I suppose we're confused, I was refering to .4. case, did you perhap=
s
>> mix that up with the latest set of tests which yields .8.?
>=20
> You're right, I was talking about .8
>=20
>> In the recent work, the most suspicious things are the new timeout
>> things, I'll read them through once I've some time (but so far I've
>> not found anything wrong in them but I of course can miss something
>> subtle). ...I've added Damian as CC if he has some idea. If you want
>> you can try with a trivial revert of that stuff, I've included a
>> patch for that below.
>=20
> I will try it.=20

Hi,
could you please printk retrans_stamp just before the return in=20
include/net/tcp.h:retransmits_timed_out()?
If the value is not monotonically increasing but is reset to 0 at some
point, this might lead to problems in tcp_write_timeout().
It's the only idea I have now.

>=20
> I just discover something not good. I use tuxonice[1] branch on houba
> for 2.6.32*.
> Although my 2.6.31 kernel is vanilla[2].
>=20
> [1] git://git.kernel.org/pub/scm/linux/kernel/git/nigelc/tuxonice-hea=
d.git
> [2] git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.=
git
>=20
> Now, I'm gonna go compile kernels again and again and make more
> tests ... :)
>=20

