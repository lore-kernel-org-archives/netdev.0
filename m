From: Luca De Cicco <ldecicco@gmail.com>
Subject: Re: TCP default congestion control in linux should be newreno
Date: Thu, 4 Dec 2008 18:50:22 +0100
Message-ID: <20081204185022.6108d19e@gmail.com>
References: <b98e548c0812030637j2851ed76xb0768932b434e35c@mail.gmail.com>
	<b98e548c0812030812i3980791y2e4135cb9c5110c0@mail.gmail.com>
	<Pine.LNX.4.64.0812041419500.26947@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Saverio Mascolo <saverio.mascolo@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:47025 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217AbYLDRvv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 12:51:51 -0500
Received: by ey-out-2122.google.com with SMTP id 6so1781971eyi.37
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2008 09:51:49 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0812041419500.26947@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Ilpo,

please find my reply in line.

On Thu, 4 Dec 2008 14:41:05 +0200 (EET)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> On Wed, 3 Dec 2008, Saverio Mascolo wrote:
>=20
> > we have added plots of cwnd at
> >=20
> > http://c3lab.poliba.it/index.php/TCP_over_Hsdpa
> >=20
> > in the case of newreno, wetwood+, bic/cubic.
>=20
> You lack the most important detail, ie., the used kernel versions!
> And also information if some sysctls were tuned or not. This is
> especially important since you seem to claim that bic is the default
> which it hasn't been for years?!
>=20

Thank you for pointing out, we employed the kernel 2.6.24 with web100
patch in order to log the internal variables. You are right, cubic is
the default, that was simply a cut & paste error.

=46or what concerns the sysctls, they are set all to the default values=
,
with the only exception of tcp_no_metrics_save that is turned on in
order not to save metrics (such as ssthresh) as specified in [1].
The other sysctls were left as default in order to assess the
performance of the algorithms as a normal user would do.

> > basically the goodput is similar with all variants  but with
> > significantly larger packet losses and timeouts with bic/cubic.
>=20
> I've never understood what exactly is wrong with the larger amount of=
=20
> packet losses if they happen before (or at the bottleneck), here
> they're just a consequence of having the larger window.

Saverio already replied to this objection. I would like to add a
further consideration. The aggressive probing phase has also the
negative effect of causing inflated values of RTT due to the excessive
queuing (see the RTT time evolution in the Cwnd/RTT figures).

>=20
> > i am pretty sure that this would happen with any algos -including
> > h-tcp- that makes the probing more aggressive leaving the van
> > jacobson linear phase.
>=20
> Probably, but you seem to completely lack the analysis to find out
> why the rtos did actually happen, whether it was due to most of the
> window lost or perhaps spurious rtos?

Why are you suggesting spurious rtos? To my uderstanding the spurious
rto should be mostly  due to the link layer retransmissions that
are orthogonal to the congestion control algorithm employed.
Let's say the average number of spurious timeouts is X, independent
from the algo, the remaining number of timeouts should be caused by
congestion, that IMHO is what differentiates the couple
NewReno/Westwood+ from the Bic/Cubic one.

However the high number of timeouts caused by Bic (and other TCP
variants) has been already observed in [2] in a different scenario.

Best regards,
Luca

--
Refs.
[1] http://www.linuxfoundation.org/en/Net:TCP_testing
[2] Saverio Mascolo, Francesco Vacirca, The effect of reverse traffic
on TCP congestion control algorithms Protocols for Fast Long-distance
Networks, Nara, Japan, Feb. 2006=20
(Available at http://c3lab.poliba.it/images/2/27/Pfldnet06.pdf)
