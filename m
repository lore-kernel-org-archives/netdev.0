From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
 skb_copy_and_csum_dev
Date: Mon, 23 Aug 2010 14:35:42 +0200
Message-ID: <1282566942.2486.31.camel@edumazet-laptop>
References: <4C6E5EA7.3040609@fs.uni-ruse.bg>
	 <20100820193835.GA6025@del.dom.local> <20100821074742.GA2367@del.dom.local>
	 <1282377058.2636.12.camel@edumazet-laptop>
	 <20100821080735.GA2409@del.dom.local>  <4C725FCB.2000304@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59873 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab0HWMfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 08:35:47 -0400
Received: by fxm13 with SMTP id 13so2842973fxm.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 05:35:46 -0700 (PDT)
In-Reply-To: <4C725FCB.2000304@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 23 ao=C3=BBt 2010 =C3=A0 14:47 +0300, Plamen Petrov a =C3=A9cr=
it :

> Well, here is the current status:
>=20
> Last I promised I will stay on 2.6.36-rc1-git for as long as possible=
,
> so here is what I achieved:
>=20
> >
> root@fs:/boot# w; uname -a
> >  12:08:18 up 3 days, 24 min,  1 user,  load average: 1.21, 1.29, 1.=
17
> > USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHA=
T
> > root     pts/0    192.168.10.159   12:04    0.00s  0.02s  0.00s w
> > Linux fs 2.6.36-rc1-FS-00127-g763008c #1 SMP Thu Aug 19 07:10:57 UT=
C 2010 i686 Intel(R) Pentium(R) D CPU 3.00GHz GenuineIntel GNU/Linux
>=20
> Yeah, 3 days and counting, right until I decided to try the freshly
> announced 2.6.36-rc2.
>=20
> So I upgraded the kernel, but left the scripts that turn GRO off for
> the tg3 card still run at system startup. This way the system ran for
> 2 and a half hours, when I decided its time to try turning GRO on.
>=20
> I first tried to turn GRO on for the tg3 nic, and the system oopsed
> immediately (if the panic screen is necessary - please, ask for it).
>=20
> After the system came back, I tried turning GRO on for the 2 RealTek
> 8139 nics, too, but ethtool only accepted turning GRO off.
>=20
> And unfortunately, I can't test if other nics will fail the same way
> as the motherboard integrated tg3 I have does, so for now, this is
> only a tg3 + GRO on problem; I don't have any other hardware to test
> with available.

There was no change in latest kernel in this area.

Should you have only tg3 cards, I guess there would be no bug.

Bug is probably a combination of :

1) tg3 + GRO , or any card enabling GRO
2) Some network code (netfilter ?)
3) a 8139too, or any card calling skb_copy_and_csum_dev()



