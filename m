From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] tcp: tsq: restore minimal amount of queueing
Date: Mon, 18 Nov 2013 08:47:28 -0800
Message-ID: <1384793248.8604.72.camel@edumazet-glaptop2.roam.corp.google.com>
References: <8761s0cqhh.fsf@natisbad.org>
	 <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
	 <87y54u59zq.fsf@natisbad.org>
	 <1384267141.28458.24.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384353174.28458.110.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8738n0ngq3.fsf@natisbad.org>
	 <pan.2013.11.13.21.59.50.578858@googlemail.com>
	 <1384386040.28458.143.camel@edumazet-glaptop2.roam.corp.google.com>
	 <pan.2013.11.13.23.52.41.470832@googlemail.com>
	 <20131117231545.GA32350@electric-eye.fr.zoreil.com>
	 <528A3FA8.8020202@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Holger =?ISO-8859-1?Q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:63630 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199Ab3KRQrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 11:47:35 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so538854pbb.18
        for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 08:47:35 -0800 (PST)
In-Reply-To: <528A3FA8.8020202@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-18 at 17:26 +0100, Holger Hoffst=C3=A4tte wrote:
> On 11/18/13 00:15, Francois Romieu wrote:
> > Holger Hoffstaette <holger.hoffstaette@googlemail.com> :
> > [...]
> >> Since I saw this with r8169->r8169 and e1000e->r8169 it's probably
> >> everyone's favourite r8169 :)
> >> Unfortunately I can't be more help but if you can suggest/whip up =
a fix
> >> I'd be happy to help test.
> >=20
> > The r8169 driver does not rely on a timer for Tx completion.
>=20
> Thankx, that's good to hear.
>=20
> > The patch below should not hurt.
>=20
> It does not seem to hurt, but neither can I notice much of a change.
> However that's probably because of some other side effects, see below=
=2E
>=20
> Do I understand the diff correctly that it makes the driver perform
> outstanding transmissions before budgeting reads? Just curious.
>=20
> > Can you describe your system a bit more specifically ?
>=20
> Server has r8169, client is either r8169 (Windows/linux) or Thinkpad
> with e1000e. Clients use NFS & Samba. Since Eric's TSQ patch the erra=
tic
> 3.12.0-vanilla behaviour has "stabilized" in the sense that latency &
> throughout became relatively smooth and more or less as expected, bot=
h
> for large copies and many small files.
>=20
> However since then I found that increasing the tcp_limit_output_bytes=
 to
> 262144 (twice the default of 128k) makes things really fly. Copying
> large files (>1GB) over NFS from the e1000e now quickly reaches the f=
ull
> 1Gb line throughput. This was really surprising.
>=20
> Apart from the laptop being relatively old and being difficult to
> benchmark due to typical power state scaling, I suspect the e1000e
> running with dynamic interrupt moderation is not completely innocent
> either. I used to turn this off some years back and had great success=
,
> but that was on Windows.

I think it would make sense to instrument the delay between the
ndo_start_xmit() and kfree_skb() for transmitted skb.

We might have a surprise for some drivers, seeing delays in the order o=
f
several ms ....
