From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.6)
Date: Wed, 12 Jan 2011 18:33:10 +0100
Message-ID: <1294853590.3981.105.camel@edumazet-laptop>
References: <20110104162930.6fa672e3@nehalam>
	 <1294208375.3420.46.camel@edumazet-laptop>
	 <20110105091718.02f8a00f@nehalam>
	 <1294248332.10633.25.camel@edumazet-laptop>
	 <20110105112104.64ad3c86@nehalam>
	 <1294286850.2723.65.camel@edumazet-laptop>
	 <20110106205549.0de56de1@nehalam> <1294667210.3491.7.camel@edumazet-laptop>
	 <20110110154414.53f33916@nehalam> <1294704031.4148.2.camel@edumazet-laptop>
	 <20110110171047.0796b6fb@nehalam> <1294726715.4148.8.camel@edumazet-laptop>
	 <1294727650.4148.20.camel@edumazet-laptop>
	 <1294816428.3447.106.camel@edumazet-laptop>
	 <20110112092739.4cdcb6f4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57827 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755029Ab1ALRdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 12:33:15 -0500
Received: by wyb28 with SMTP id 28so803626wyb.19
        for <netdev@vger.kernel.org>; Wed, 12 Jan 2011 09:33:14 -0800 (PST)
In-Reply-To: <20110112092739.4cdcb6f4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 12 janvier 2011 =C3=A0 09:27 -0800, Stephen Hemminger a =C3=
=A9crit :
> On Wed, 12 Jan 2011 08:13:48 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Hi Stephen, here is my v0.6 version :
> >=20
> > - Added sanity checks before kcalloc()/kzalloc()
> > - Added a __GFP_NOWARN to kcalloc()
> > - Added call to qdisc_bstats_update() after commit bfe0d0298f2a67d9=
4d5
> > (net_sched: factorize qdisc stats handling)
> >=20
> > TODO :
> > - Added a stat specific update to track CHOKe probabilistic dual-dr=
ops
> >   I temporarily use requeues counter to make sure our code works
>=20
> I am going to redo stats and config.
> Should thresholds be packet or byte based? I prefer packet
> Also leaning towards merging qmax and qlimit together.

I believe CHOKe spirit is per packet, I agree with you.

(This makes the tab[] array sizing directly depends on ctl->limit, not
on a computation ctl->limit/smallest_packet_size)

Not sure we can merge qmax and qlimit, are you sure its OK with CHOKe
paper and experimental results ?
(Sorry I cant spend too much time right now to check this point)



