From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Multicast routing stops functioning after 4G multicast packets
 recived.
Date: Sun, 05 Jan 2014 11:12:17 -0800
Message-ID: <1388949137.12212.166.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131219144816.33310@gmx.com>
	 <alpine.LFD.2.11.1401042143330.1598@ja.home.ssi.bg>
	 <20140104233840.GD25828@order.stressinduktion.org>
	 <alpine.LFD.2.11.1401051050320.1538@ja.home.ssi.bg>
	 <20140105104145.GF25828@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>,
	Bob Falken <NetFestivalHaveFun@gmx.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:62713 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbaAETMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 14:12:19 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so17584586pbc.21
        for <netdev@vger.kernel.org>; Sun, 05 Jan 2014 11:12:19 -0800 (PST)
In-Reply-To: <20140105104145.GF25828@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-05 at 11:41 +0100, Hannes Frederic Sowa wrote:
> On Sun, Jan 05, 2014 at 10:56:55AM +0200, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Sun, 5 Jan 2014, Hannes Frederic Sowa wrote:
> > 
> > > I guess we should just try. I somehow forgot to look after that. Thanks
> > > for reminding, Julian.
> > 
> > 	If that patch solves the problem, do not forget
> > to include same fix for ip6mr_fib_lookup(). As for net/decnet/,
> > it looks ok, it uses fib_rule_put() in dn_fib_res_put().
> 
> Thanks, I had IPv6 on my radar but did not check for other callers.

BTW, I wonder if the old kernels (2.6.32 & 2.6.34) need something as
well ?

Before commit ebc0ffae5dfb444 and commit 7fa7cb7109d0, it looks like we
had an overflow in fib_rule_get() and refcnt was wrapping.

So maybe we should add a fib_rule_put() for stable kernels, and use
FIB_LOOKUP_NOREF on next kernels ...
