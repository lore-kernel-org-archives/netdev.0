From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 04:40:06 +0200
Message-ID: <1271299206.16881.1764.camel@edumazet-laptop>
References: <1265568122.3688.36.camel@bigi> <1271245986.3943.55.camel@bigi>
	 <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi> <20100414124426.6aee95c3@nehalam>
	 <1271276568.4567.59.camel@bigi>
	 <1271276855.16881.1756.camel@edumazet-laptop>
	 <z2y65634d661004141345o9bdcf759sf266866931823baf@mail.gmail.com>
	 <1271278661.16881.1761.camel@edumazet-laptop>
	 <v2s412e6f7f1004141551u5764604h3ab092ee9e70a650@mail.gmail.com>
	 <20100414160220.43a62999@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Tom Herbert <therbert@google.com>,
	hadi@cyberus.ca, netdev@vger.kernel.org, robert@herjulf.net,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:40749 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755783Ab0DOCkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 22:40:15 -0400
Received: by bwz25 with SMTP id 25so959677bwz.28
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 19:40:12 -0700 (PDT)
In-Reply-To: <20100414160220.43a62999@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 avril 2010 =C3=A0 16:02 -0700, Stephen Hemminger a =C3=A9=
crit :
> On Thu, 15 Apr 2010 06:51:29 +0800
> Changli Gao <xiaosuo@gmail.com> wrote:
>=20
> > On Thu, Apr 15, 2010 at 4:57 AM, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
> > >
> > > RPS can be tuned (Changli wants a finer tuning...), it would be
> > > intereting to tune multiqueue devices too. I dont know if its pos=
sible
> > > right now.
> > >
> > > On my Nehalem machine (16 logical cpus), its NetXtreme II BCM5771=
1E
> > > 10Gigabit has 16 queues. It might be good to use less queues acco=
rding
> > > to your results on some workloads, and eventually use RPS on a se=
cond
> > > layering.
> >=20
> > My idear is: run a daemon in userland to monitor the softnet
> > statistics, and tun the RPS setting if necessary. It seems that the
> > current softnet statistics data isn't correct.
> >=20
> > Long time ago, I did a test, and the conclution was
> > call_function_single IPI was more expensive than resched IPI, so I
> > moved to kernel thread from softirq for packet processing. I'll red=
o
> > the test later.
> >=20
>=20
> The big thing is data, data, data... Performance can only be examined
> with real hard data with multiple different kind of hardware.  Also, =
check for
> regressions in lmbench and TPC benchmarks. Yes this is hard, but pape=
rs
> on this would allow for rational rather than speculative choices.
>=20
> Adding more tuning knobs is not the answer unless you can show when
> the tuning helps.
>=20

Agree 100%, and irqbalance is the existing daemon. It should be used an=
d
changed if necessary.

Changli, my stronges argument about your patches is that our scheduler
and memory affinity api (numactl driven) is bitmask oriented, giving th=
e
same weight to individual cpu or individual memory node.



