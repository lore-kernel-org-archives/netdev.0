From: Yuchung Cheng <ycheng@google.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Wed, 27 Apr 2011 10:39:54 -0700
Message-ID: <BANLkTi=i5ZftuL++ORuy=n_yM_futWYoZw@mail.gmail.com>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
 <BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com> <BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
 <201104271157.49386.carsten@wolffcarsten.de> <BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carsten Wolff <carsten@wolffcarsten.de>,
	John Heffner <johnwheffner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Zimmermann Alexander <zimmermann@nets.rwth-aachen.de>,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: Dominik Kaspar <dokaspar.ietf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:18371 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755116Ab1D0RkS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 13:40:18 -0400
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p3RHeFd9014402
	for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 10:40:16 -0700
Received: from yib2 (yib2.prod.google.com [10.243.65.66])
	by wpaz5.hot.corp.google.com with ESMTP id p3RHdVCQ015193
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 10:40:14 -0700
Received: by yib2 with SMTP id 2so682756yib.10
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 10:40:14 -0700 (PDT)
In-Reply-To: <BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dominik,

On Wed, Apr 27, 2011 at 9:22 AM, Dominik Kaspar <dokaspar.ietf@gmail.co=
m> wrote:
>
> Hi Carsten,
>
> Thanks for your feedback. I made some new tests with the same setup o=
f
> packet-based forwarding over two emulated paths (600 KB/s, 10 ms) +
> (400 KB/s, 100 ms). In the first experiments, which showed a step-wis=
e
> adaptation to reordering, SACK, DSACK, and Timestamps were all
> enabled. In the experiments, I individually disabled these three
> mechanisms and saw the following:
>
> - Disabling timestamps causes TCP to never adjust to reordering at al=
l.
> - Disabling SACK allows TCP to adapt very rapidly ("perfect" aggregat=
ion!).

Did you enable tcp_fack when sack is enabled? this may make a (big)
difference. FACK assumes little network reordering and mark packet
losses more aggressively.

> - Disabling DSACK has no obvious impact (still a step-wise throughput=
).
>
> Is there an explanation for why turning off SACK can be beneficial in
> the presence of packet reordering? That sounds pretty
> counter-intuitive to me... I thought SACK=3D1 always performs better
> than SACK=3D0. The results are also illustrated in the following plot=
=2E
> For each setting, there are three runs, which all exhibit a similar
> behavior:
>
> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-02-sack.png
>
> Greetings,
> Dominik
>
> On Wed, Apr 27, 2011 at 11:57 AM, Carsten Wolff <carsten@wolffcarsten=
=2Ede> wrote:
> > Hi all,
> >
> > On Tuesday 26 April 2011, John Heffner wrote:
> >> First, TCP is definitely not designed to work under such condition=
s.
> >> For example, assumptions behind RTO calculation and fast retransmi=
t
> >> heuristics are violated. =A0However, in this particular case my fi=
rst
> >> guess is that you are being limited by "cwnd moderation," which wa=
s
> >> the topic of recent discussion here. =A0Under persistent reorderin=
g,
> >> cwnd moderation can inhibit the ability of cwnd to grow.
> >
> > it's not just cwnd moderation (of which I'm still in favor, even th=
ough I lost
> > the argument by inactivity ;-)).
> >
> > Anyway, there are a lot of things in reordering handling that can b=
e improved.
> > Our group (Alexander, Lennart, Arnd, myself and others) has worked =
on the
> > problem for a long time now. This work resulted in an algorithm tha=
t is in
> > large parts TCP-NCR (RFC4653), but also utilizes information gather=
ed by
> > reordering detection for determination of a good DupThresh, fixes a=
 few
> > problems in RFC4653 and improves on the reordering detection in Lin=
ux when the
> > connection has no timestamps option. We implemented "pure" TCP-NCR =
and our own
> > variant in Linux using a modular framework similar to the congestio=
n control
> > modules. A lot of measurements and evaluation have gone into the co=
mparison of
> > the three algorithms. We are now very close(TM) to a final patch, t=
hat is more
> > suited for publication on this list and integrates our algorithm in=
to tcp*.
> > [hc] without introducing the overhead of that modular framework.
> >
> > Greetings,
> > Carsten
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
