From: Dominik Kaspar <dokaspar.ietf@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Wed, 27 Apr 2011 18:22:55 +0200
Message-ID: <BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	<BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com>
	<BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
	<201104271157.49386.carsten@wolffcarsten.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Heffner <johnwheffner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Zimmermann Alexander <zimmermann@nets.rwth-aachen.de>,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: Carsten Wolff <carsten@wolffcarsten.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:41725 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604Ab1D0QW4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 12:22:56 -0400
Received: by iwn34 with SMTP id 34so1493868iwn.19
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 09:22:55 -0700 (PDT)
In-Reply-To: <201104271157.49386.carsten@wolffcarsten.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Carsten,

Thanks for your feedback. I made some new tests with the same setup of
packet-based forwarding over two emulated paths (600 KB/s, 10 ms) +
(400 KB/s, 100 ms). In the first experiments, which showed a step-wise
adaptation to reordering, SACK, DSACK, and Timestamps were all
enabled. In the experiments, I individually disabled these three
mechanisms and saw the following:

- Disabling timestamps causes TCP to never adjust to reordering at all.
- Disabling SACK allows TCP to adapt very rapidly ("perfect" aggregatio=
n!).
- Disabling DSACK has no obvious impact (still a step-wise throughput).

Is there an explanation for why turning off SACK can be beneficial in
the presence of packet reordering? That sounds pretty
counter-intuitive to me... I thought SACK=3D1 always performs better
than SACK=3D0. The results are also illustrated in the following plot.
=46or each setting, there are three runs, which all exhibit a similar
behavior:

http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-02-sack.png

Greetings,
Dominik

On Wed, Apr 27, 2011 at 11:57 AM, Carsten Wolff <carsten@wolffcarsten.d=
e> wrote:
> Hi all,
>
> On Tuesday 26 April 2011, John Heffner wrote:
>> First, TCP is definitely not designed to work under such conditions.
>> For example, assumptions behind RTO calculation and fast retransmit
>> heuristics are violated. =A0However, in this particular case my firs=
t
>> guess is that you are being limited by "cwnd moderation," which was
>> the topic of recent discussion here. =A0Under persistent reordering,
>> cwnd moderation can inhibit the ability of cwnd to grow.
>
> it's not just cwnd moderation (of which I'm still in favor, even thou=
gh I lost
> the argument by inactivity ;-)).
>
> Anyway, there are a lot of things in reordering handling that can be =
improved.
> Our group (Alexander, Lennart, Arnd, myself and others) has worked on=
 the
> problem for a long time now. This work resulted in an algorithm that =
is in
> large parts TCP-NCR (RFC4653), but also utilizes information gathered=
 by
> reordering detection for determination of a good DupThresh, fixes a f=
ew
> problems in RFC4653 and improves on the reordering detection in Linux=
 when the
> connection has no timestamps option. We implemented "pure" TCP-NCR an=
d our own
> variant in Linux using a modular framework similar to the congestion =
control
> modules. A lot of measurements and evaluation have gone into the comp=
arison of
> the three algorithms. We are now very close(TM) to a final patch, tha=
t is more
> suited for publication on this list and integrates our algorithm into=
 tcp*.
> [hc] without introducing the overhead of that modular framework.
>
> Greetings,
> Carsten
>
