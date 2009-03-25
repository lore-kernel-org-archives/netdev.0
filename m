From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Wed, 25 Mar 2009 16:21:00 +0100
Message-ID: <OF6FCD73B2.9477636F-ONC1257584.0053EFCE-C1257584.005451CC@transmode.se>
References: <1237987849.2194.9.camel@gentoo-jocke.transmode.se> <20090325142540.GA20944@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: leoli@freescale.com,
	'linuxppc-dev Development' <linuxppc-dev@ozlabs.org>,
	Netdev <netdev@vger.kernel.org>
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:58975 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755143AbZCYPVE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 11:21:04 -0400
In-Reply-To: <20090325142540.GA20944@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov <avorontsov@ru.mvista.com> wrote on 25/03/2009 15:25:40:
> 
> On Wed, Mar 25, 2009 at 02:30:49PM +0100, Joakim Tjernlund wrote:
> > >>From 1c2f23b1f37f4818c0fd0217b93eb38ab6564840 Mon Sep 17 00:00:00 
2001
> > From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > Date: Tue, 24 Mar 2009 10:19:27 +0100
> > Subject: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context.
> >  Also increase NAPI weight somewhat.
> >  This will make the system alot more responsive while
> >  ping flooding the ucc_geth ethernet interaface.
> 
> Some time ago I've tried a similar thing for this driver, but during
> tcp (or udp I don't quite remember) netperf tests I was getting tx
> watchdog timeouts after ~2-5 minutes of work. I was testing with a
> gigabit and 100 Mbit link, with 100 Mbit link the issue was not
> reproducible.
> 
> Though, I recalling I was doing a bit more than your patch: I was
> also clearing the TX events in the ucce register before calling
> ucc_geth_tx, that way I was trying to avoid stale interrupts. That

Sure, but that is another patch I think.

> helped to increase an overall performance (not only responsiveness),
> but as I said my approach didn't pass the tests.
> 
> I don't really think that your patch may cause this, but can you
> try netperf w/ this patch applied anyway? And see if it really
> doesn't cause any issues under stress?

Ran this on my host against my target board:
 netperf -t UDP_RR  -H 192.168.1.16
 netperf -t UDP_STREAM -H 192.168.1.16
 netperf -t TCP_STREAM -H 192.168.1.16
 netperf -t TCP_SENDFILE -H 192.168.1.16
 netperf -t TCP_MAERTS -H 192.168.1.16
 netperf -t TCP_RR -H 192.168.1.16
 netperf -t TCP_CRR -H 192.168.1.16

Didn't notice any timeouts, but I only have 100Mbit interfaces.
