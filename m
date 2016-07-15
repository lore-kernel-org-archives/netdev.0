From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH v2 08/10] net: sched: pfifo_fast use alf_queue
Date: Fri, 15 Jul 2016 15:48:02 -0700
Message-ID: <20160715224759.GA12613@ast-mbp.thefacebook.com>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
 <20160714062312.8270.65942.stgit@john-Precision-Tower-5810>
 <20160714234207.GA93671@ast-mbp.thefacebook.com>
 <57882945.4090101@gmail.com>
 <20160715132329.0d04ac42@redhat.com>
 <57896124.6090402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, fw@strlen.de,
	jhs@mojatatu.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34754 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbcGOWsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 18:48:08 -0400
Received: by mail-pa0-f67.google.com with SMTP id hh10so6803800pac.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 15:48:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57896124.6090402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 15, 2016 at 03:18:12PM -0700, John Fastabend wrote:
>=20
> nolock (pfifo_fast)
> 1:  1440293 1421602 1409553 1393469 1424543
> 2:  1754890 1819292 1727948 1797711 1743427
> 4:  3282665 3344095 3315220 3332777 3348972
> 8:  2940079 1644450 2950777 2922085 2946310
> 12: 2042084 2610060 2857581 3493162 3104611
>=20
> lock (pfifo_fast)
> 1:  1471479 1469142 1458825 1456788 1453952
> 2:  1746231 1749490 1753176 1753780 1755959
> 4:  1119626 1120515 1121478 1119220 1121115
> 8:  1001471  999308 1000318 1000776 1000384
> 12:  989269  992122  991590  986581  990430
>=20
> So then if we just use the first test example because I'm being a
> bit lazy and don't want to calculate the avg/mean/whatever we get
> a pfifo_fast chart like,
>=20
>       locked             nolock           diff
> ---------------------------------------------------
> 1     1471479            1440293          =E2=88=92  31186
> 2     1746231            1754890          +   8659
> 4     1119626            3282665          +2163039
> 8     1119626            2940079          +1820453
> 12     989269            2857581*         +1868312
=2E..
> Also I'm going to take a look at Jesper's microbenchmark numbers but =
I
> think if I can convince myself that using skb_array helps or at least
> does no harm I might push to have this include with skb_array and the=
n
> work on optimizing the ring type/kind/etc. as a follow up patch.
> Additionally it does seem to provide goodness on the pfifo_fast singl=
e
> queue case.

Agree. I think the pfifo_fast gains worth applying this patch set
as-is and work on further improvements in follow up.
