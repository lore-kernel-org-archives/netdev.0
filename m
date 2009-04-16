From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 21:43:53 +0200
Message-ID: <49E78A79.6050604@cosmosbay.com>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44217 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756788AbZDPTof convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 15:44:35 -0400
In-Reply-To: <alpine.DEB.1.10.0904161151330.13531@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> The following are results of lantency measurements using udpping
> (available from http://gentwo.org/ll). It shows that significant late=
ncies
> were added since 2.6.27. I surely wish we could get back to times bel=
ow 90
> microseconds.
>=20
> The tests were done over 1G ethernet using
> 09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5754
> Gigabit Ethernet PCI Express (rev 02)
>=20
> Results:
>=20
>            2.6.22 2.6.23 2.6.24 2.6.25 2.6.26 2.6.27 2.6.28 2.6.29
> 40 Bytes    89.50  90.75  89.61  91.51  91.89  99.17  99.80  99.34
> 400 Bytes   98.58 101.44  97.85  99.61 100.36 117.96 118.10 126.79
> 1400 Bytes 152.76 153.75 153.85	156.22 156.66 163.92 165.54 166.04
>=20
> Compared to 2.6.22 2.6.23 2.6.24 2.6.25 2.6.26 2.6.27 2.6.28 2.6.29
> 40 Bytes            -1.4%  -0.1%  -2.2%  -2.6%  -9.8%  -10.3% -9.9%
> 400 Bytes           -2.8%   0.7%  -1.0%  -1.8% -16.4%  -16.5%-22.2%
> 1400 Bytes          -0.6%  -0.7%  -2.2%  -2.5%  -6.8%  -7.7%  -8.0%
>=20
> I presented these numbers with some nice graphs at the Linux Collab S=
ummit
> last week.
>=20
> See
> http://www.kernel.org/pub/linux/kernel/people/christoph/collab-spring=
-2009/Collab-summit-2009-sf.pdf
>=20

Is it a bnx2 or tg3 driver ?

copybreak feature could explain a regression for small packets, since
an extra copy is done.

It would be sane to always set on both machines :
ethtool -C eth0 rx-usecs 0 rx-frames 1
prior to your tests...


