From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Wed, 09 Sep 2009 00:52:41 +0200
Message-ID: <4AA6E039.4000907@gmail.com>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41294 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbZIHWwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 18:52:41 -0400
In-Reply-To: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> Looks like we have a regression since 2.6.22 due to latency increases=
 in
> the network stack? The following is the result of measuring latencies=
 for
> UDP multicast traffic at packet rates of 10pps 100pps 1kpps 10kpps an=
d
> 100k pps. Two system running "mcast -n1 -r<rate>" (mcast tool from
> http://gentwo.org/ll).
>=20
> Measurements in microseconds for one hop using bnx2 on Dell R610 (64 =
bit
> 2.6.31-rc9) and Dell 1950 (32 bit 2.6.22.19 3.3Ghz). Dell R610 RX use=
cs
> tuned to 0. 32 bit tuned to 1 (NIC is flaky at 0).
>=20
> Kernel			10pps	100pps	1kpps	10kpps	100kpps
> ---------------------------------------------------------------
> 2.6.22 (32bit)		30	29.5	29	30	41
> 2.6.31-rc9(64 bit)	64	63	46	30	40
>=20
> The only minor improvement is at a rate of 100kpps. All rates
> lower than 10k regress significantly.
>=20
> Could there be something wrong with the bnx2 interrupt routing? They =
all
> end up on cpu0 here. There are 8 of them in a system with 16 "process=
ors".
> How do those need to be configured? There are some sparse comments in
> Documentation/networking/multiqueue.txt but the text does not say any=
thing
> about the irq routing.
>=20
>=20

Hi Christoph

In order to reproduce this here, could you tell me if you use=20

Producer linux-2.6.22 -> Receiver 2.6.22
Producer linux-2.6.31 -> Receiver 2.6.31

Or a mix of
Producer linux-2.6.31 -> Receiver 2.6.22
Producer linux-2.6.22 -> Receiver 2.6.31-rc9

Not clear what is your exact setup

Thanks
