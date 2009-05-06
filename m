From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: Re: bond + tc regression ?
Date: Wed, 6 May 2009 16:11:17 +0300
Message-ID: <20090506131117.GA10105@francoudi.com>
References: <20090505174135.GA29716@francoudi.com> <20090506061010.GA4571@ff.dom.local> <20090506103616.GA25750@francoudi.com> <20090506104808.GA6115@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:2398 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756557AbZEFNLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 09:11:22 -0400
Content-Disposition: inline
In-Reply-To: <20090506104808.GA6115@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 06, 2009 at 10:48:08AM +0000, Jarek Poplawski wrote:

> > > >> ifconfig -a
> > > > 
> > > > bond0     Link encap:Ethernet  HWaddr 00:1B:24:BD:E9:CC
> > > >           inet addr:xxx.xxx.135.44  Bcast:xxx.xxx.135.47  Mask:255.255.255.248
> > > >           inet6 addr: fe80::21b:24ff:febd:e9cc/64 Scope:Link
> > > >           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
> > > >           RX packets:436076190 errors:0 dropped:391250 overruns:0 frame:0
> > > >           TX packets:2620156321 errors:0 dropped:0 overruns:0 carrier:0
> > > >           collisions:0 txqueuelen:0
> > > >           RX bytes:4210046233 (3.9 GiB)  TX bytes:2520272242 (2.3 GiB)
> > > 
> > > Could you try e.g.: ifconfig bond0 txqueuelen 1000
> > > before tc qdisc add?
> > 
> > The drops on ifconfig are not increasing - these numbers are there from some tests made
> > before.
> > 
> 
> I'm not sure what do you mean? IMHO you don't use qdiscs properly,
> so any TX problems end with drops. (Older kernel versions could mask
> this problem with requeuing.)

Apologies, my bad, I misread what you wrote.

txqueuelen 1000 fixes the qdisc drops. I didn't notice that bond interfaces have it set to 0 by default.

As suggested by Eric earlier, the drops also disappear if I bind each NIC to a single CPU. That was the 
default on older kernels and perhaps that's why the issue came up only on 2.6.28.

-- 
Best Regards
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel, Cyprus - www.prime-tel.com
