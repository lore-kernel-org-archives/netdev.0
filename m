From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: 4.6.3, pppoe + shaper workload, skb_panic / skb_push /
 ppp_start_xmit
Date: Thu, 28 Jul 2016 13:09:48 +0200
Message-ID: <20160728110948.GA3046@alphalink.fr>
References: <c72d23549eaa7aadee1a66a6bb788a4a@nuclearcat.com>
 <CAM_iQpWuCw6Bgm=1BWMkoFkuav5xV+FyKPq0Ef+3N_qpQqv=AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nuclearcat@nuclearcat.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:57226 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756672AbcG1LJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 07:09:52 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpWuCw6Bgm=1BWMkoFkuav5xV+FyKPq0Ef+3N_qpQqv=AA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 10:31:18AM -0700, Cong Wang wrote:
> On Mon, Jul 11, 2016 at 12:45 PM,  <nuclearcat@nuclearcat.com> wrote:
> > Hi
> >
> > On latest kernel i noticed kernel panic happening 1-2 times per day. It is
> > also happening on older kernel (at least 4.5.3).
> >
> ...
> >  [42916.426463] Call Trace:
> >  [42916.426658]  <IRQ>
> >
> >  [42916.426719]  [<ffffffff81843786>] skb_push+0x36/0x37
> >  [42916.427111]  [<ffffffffa00e8ce5>] ppp_start_xmit+0x10f/0x150
> > [ppp_generic]
> >  [42916.427314]  [<ffffffff81853467>] dev_hard_start_xmit+0x25a/0x2d3
> >  [42916.427516]  [<ffffffff818530f2>] ?
> > validate_xmit_skb.isra.107.part.108+0x11d/0x238
> >  [42916.427858]  [<ffffffff8186dee3>] sch_direct_xmit+0x89/0x1b5
> >  [42916.428060]  [<ffffffff8186e142>] __qdisc_run+0x133/0x170
> >  [42916.428261]  [<ffffffff81850034>] net_tx_action+0xe3/0x148
> >  [42916.428462]  [<ffffffff810c401a>] __do_softirq+0xb9/0x1a9
> >  [42916.428663]  [<ffffffff810c4251>] irq_exit+0x37/0x7c
> >  [42916.428862]  [<ffffffff8102b8f7>] smp_apic_timer_interrupt+0x3d/0x48
> >  [42916.429063]  [<ffffffff818cb15c>] apic_timer_interrupt+0x7c/0x90
> 
> Interesting, we call a skb_cow_head() before skb_push() in ppp_start_xmit(),
> I have no idea why this could happen.
>
The skb is corrupted: head is at ffff8800b0bf2800 while data is at
ffa00500b0bf284c.

Figuring out how this corruption happened is going to be hard without a
way to reproduce the problem.

Denys, can you confirm you're using a vanilla kernel?
Also I guess the ppp devices and tc settings are handled by accel-ppp.
If so, can you share more info about your setup (accel-ppp.conf, radius
attributes, iptables...) so that I can try to reproduce it on my
machines?

Regards

Guillaume
