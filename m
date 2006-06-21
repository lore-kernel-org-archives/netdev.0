From: Krzysztof Matusik <kyf@arterm.pl>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Wed, 21 Jun 2006 16:33:07 +0200
Message-ID: <200606211633.08198.kyf@arterm.pl>
References: <1150278004.26181.35.camel@localhost.localdomain> <200606211421.05606.kyf@arterm.pl> <44994192.5050807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from b162.lepiej.pl ([217.153.189.162]:52419 "EHLO b02.lepiej.pl")
	by vger.kernel.org with ESMTP id S1751582AbWFUOdO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 10:33:14 -0400
Received: from [10.0.0.25] ([213.199.219.69])
	(authenticated bits=0)
	by b02.lepiej.pl (8.13.7/8.13.7/Debian-1) with ESMTP id k5LEXAOB025441
	(version=TLSv1/SSLv3 cipher=EXP1024-RC4-SHA bits=56 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 16:33:12 +0200
To: netdev@vger.kernel.org
In-Reply-To: <44994192.5050807@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dnia =C5=9Broda, 21 czerwca 2006 14:54, Patrick McHardy napisa=C5=82:
> > I'd love to see this one implemented. I'm using HFSC more than a ye=
ar and
> > it never provides proper QoS on ATM/ADSL links; low delays can neve=
r be
> > achieved even with significant throttling below the h/w link bandwi=
dth.
>
> Mhh .. I trust you picked a proper clocksource and timer frequency?

250Hz or 1000Hz and jiffies (for a SMP machine)
I don't mean I've got big delays though and those are lowest with HFSC,=
 when=20
link is satiated.

IMHO since ATM is sending small packets constantly thorough its link (A=
TM=20
specific) encapsulated data defragmentation cannot simply be achieved (=
or it=20
simply isn't done by modems). As a result one can't simply throttle qdi=
sc=20
basing on computations like=20
UpperLimit =3D ( bandwidth*(1 - header_bits/frame_size )
having bandwidth specified by ATM link speed rate, as it can be reporte=
d by=20
modem, and expect it won't ever be congested.
This seems to be main problem. Link asymmetry, window size etc don't af=
fect=20
line congestion and so delays that much I suppose.
The same with incorrect timer :-).

> I hacked up a patch yesterday. I want to do a bit more testing before
> posting it, but its hard to really test the effectiveness because eve=
n
> without this patch my DSL line already delivers higher throughput and
> much better delay than it should (its a throttled SDSL line sold as
> ADSL). I'll try to do some testing on an ethernet link now.

I'll follow this thread then.

regards
