From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [regression, 2.6.37-rc1] 'ip link tap0 up' stuck in do_exit()
Date: Wed, 8 Dec 2010 14:47:12 +0100
Message-ID: <20101208134712.GB16923@redhat.com>
References: <20101103062609.GB31163@dastard> <1288768402.2467.665.camel@edumazet-laptop> <20101103103448.GA9169@dastard> <20101103112936.GB9169@dastard> <20101104002140.GA13830@dastard> <20101104054718.GC5210@cr0.nay.redhat.com> <20101208100245.01cf23c5@schatten.dmk.lab> <20101208134116.GA16923@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Dave Chinner <david@fromorbit.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Mickler <florian@mickler.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34410 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755055Ab0LHNx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 08:53:59 -0500
Content-Disposition: inline
In-Reply-To: <20101208134116.GA16923@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08, Oleg Nesterov wrote:
>
> On 12/08, Florian Mickler wrote:
> >
> > [ ccing Ingo and Oleg ] as suggested
>
> Well. Of course I can't explain this bug. But, looking at this email
> I do not see amything strange in exit/schedule/etc.
>
> > > >> > > > This is resulting in the command 'ip link set tap0 up' hanging as a zombie:
> > > >> > > >
> > > >> > > > root      3005     1  0 16:53 pts/3    00:00:00 /bin/sh /vm-images/qemu-ifup tap0
> > > >> > > > root      3011  3005  0 16:53 pts/3    00:00:00 /usr/bin/sudo /sbin/ip link set tap0 up
> > > >> > > > root      3012  3011  0 16:53 pts/3    00:00:00 [ip] <defunct>
>
> That is. ip is a zombie.

And. I do not know if this matters or not, but "the command 'ip link
set tap0 up' hanging as a zombie" does not look right.

This was spawned by

> >> > > > if [ -n "$1" ];then
> >> > > >         /usr/bin/sudo /sbin/ip link set $1 up
> >> > > >         sleep 0.5s
> >> > > >         /usr/bin/sudo /usr/sbin/brctl addif $switch $1
> >> > > >      exit 0
> >> > > > fi

The command does not hang. But it forks the child with pid == 3012,
this child exits.

Oleg.

