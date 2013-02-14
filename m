From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tuntap: Overload handling
Date: Thu, 14 Feb 2013 09:01:30 -0800
Message-ID: <1360861290.6884.55.camel@edumazet-glaptop>
References: <CAGUzgdK9U3hreLxtc6eP3CSpLsfhkn2ZKpFp9_VJhWr2gz0uCQ@mail.gmail.com>
	 <CAGUzgdJOLmOyd9dd=Ht-qgZ9B-or59pDwaUY28DrbnL4BKFPcw@mail.gmail.com>
	 <1360859547.6884.51.camel@edumazet-glaptop>
	 <20130214164053.GB18721@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sebastian =?ISO-8859-1?Q?P=F6hn?=
	<sebastian.poehn@googlemail.com>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:49729 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934609Ab3BNRBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 12:01:34 -0500
Received: by mail-pa0-f48.google.com with SMTP id hz10so1388408pad.21
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 09:01:33 -0800 (PST)
In-Reply-To: <20130214164053.GB18721@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 18:42 +0200, Michael S. Tsirkin wrote:

> Hmm so ~1000 packets in the tun queue is not enough?
> You always have the option to increase it some more ...
> 
> > You should ask Michael S. Tsirkin, as he removed the flow control
> > in commit 5d097109257c03a71845729f8db6b5770c4bbedc
> > (tun: only queue packets on device)
> > 
> 
> Eric in the past you said the following things
> (http://lkml.indiana.edu/hypermail/linux/kernel/1204.1/00784.html)
> > > In your case I would just not use qdisc at all, like other virtual
> > > devices.
> ...
> > > Anyway, with a 500 packet limit in TUN queue itself, qdisc layer should
> > > be always empty. Whats the point storing more than 500 packets for a
> > > device ? Thats a latency killer.
> you don't think this applies, anymore?
> 

Users have the choice to setup a qdisc or not.

Having no qdisc can help raw performance, at the expense of bufferbloat.
Thats all I was saying.

It seems tun.c has no longer the possibility to effectively use a qdisc,
(allowing the queue to buildup at qdisc layer)
