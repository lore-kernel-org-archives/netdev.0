From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 ipv6_select_ident
Date: Wed, 21 Dec 2011 21:28:52 +0100
Message-ID: <1324499332.2621.7.camel@edumazet-laptop>
References: <4EF200BB.7000209@bootc.net>
	  <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <4EF2117F.6000803@bootc.net>
	  <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324490401.2301.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF23BF2.4000601@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Chris Boot <bootc@bootc.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60524 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab1LUU26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 15:28:58 -0500
In-Reply-To: <4EF23BF2.4000601@bootc.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 20:05 +0000, Chris Boot a =C3=A9=
crit :
> On 21/12/2011 18:00, Eric Dumazet wrote:
> > Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 18:36 +0100, Eric Dumazet =
a =C3=A9crit :
> >
> >> Good point, thats a different problem then, since 3.1 is not suppo=
sed to
> >> have this bug.
> >>
> >> It seems rt->rt6i_peer points to invalid memory in your crash.
> >>
> >> (RBX=3D00000000000001f4)
> >>
> >> 8b 83 a4 00 00 00       mov    0xa4(%rbx),%eax    p->refcnt
> >> 1f4+a4 ->  CR2=3D0000000000000298
> >>
> > It would help if you can confirm latest linux tree can reproduce th=
e
> > bug.
>=20
> Hi Eric,
>=20
> I just built a v3.2-rc6-140-gb9e26df with the same config as the Debi=
an=20
> 3.1.0 kernel. I can reproduce the bug just as easily with this kernel=
 as=20
> with the Debian kernel. Unfortunately I wasn't able to get an entire=20
> trace, for some reason it didn't appear to be printed to the serial p=
ort=20
> and hung after the (long) list of loaded kernel modules. The crash=20
> happens at the same offset:
>=20

Thanks !

Oh well, br_netfilter fake_rtable strikes again.

I'll cook a patch in a couple of minutes...
