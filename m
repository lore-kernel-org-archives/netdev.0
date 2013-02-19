From: Marc MERLIN <marc@merlins.org>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs copies out
Date: Mon, 18 Feb 2013 21:26:39 -0800
Message-ID: <20130219052639.GA21764@merlins.org>
References: <1334030180.13293.98.camel@edumazet-glaptop> <20120410051127.GA32048@merlins.org> <1334038263.2907.1.camel@edumazet-glaptop> <20120411052733.GA17352@merlins.org> <20120715215935.GF24420@merlins.org> <1342419529.3265.12217.camel@edumazet-glaptop> <20120716151826.GA10586@merlins.org> <1342455717.2830.14.camel@edumazet-glaptop> <20130219040557.GB4778@merlins.org> <1361251033.19353.120.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Larry.Finger@lwfinger.net,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from magic.merlins.org ([209.81.13.136]:47058 "EHLO
	mail1.merlins.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab3BSF0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 00:26:43 -0500
Content-Disposition: inline
In-Reply-To: <1361251033.19353.120.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 18, 2013 at 09:17:13PM -0800, Eric Dumazet wrote:
> > chrome: page allocation failure: order:1, mode:0x4020
> > Pid: 8730, comm: chrome Tainted: G           O 3.7.8-amd64-preempt-20121226-fixwd #1
> > Call Trace:
> >  <IRQ>  [<ffffffff810d5f38>] warn_alloc_failed+0x117/0x12c
> >  [<ffffffff810d8cfd>] __alloc_pages_nodemask+0x66a/0x702
> >  [<ffffffff8108a948>] ? arch_local_irq_save+0x15/0x1b
> >  [<ffffffff811064af>] alloc_pages_current+0xcd/0xee
> >  [<ffffffffa039b579>] iwl_rx_allocate+0x8c/0x271 [iwlwifi]
> >  [<ffffffffa039c24e>] iwl_irq_tasklet+0x7e5/0x91c [iwlwifi]
> >  [<ffffffff8104805e>] tasklet_action+0x80/0xd2
> >  [<ffffffff81047c99>] __do_softirq+0xdf/0x1c5
> >  [<ffffffff814c1ed6>] ? _raw_spin_lock+0x1b/0x1f
> >  [<ffffffff810a7f37>] ? handle_irq_event+0x4d/0x62
> >  [<ffffffff814c7f5c>] call_softirq+0x1c/0x30
> >  [<ffffffff8101104e>] do_softirq+0x41/0x7f
> >  [<ffffffff81047e52>] irq_exit+0x3f/0xa7
> >  [<ffffffff81010d40>] do_IRQ+0x88/0x9f
> >  [<ffffffff814c246d>] common_interrupt+0x6d/0x6d
> >  <EOI> Mem-Info:
> 
> You could try to load iwlwifi with amsdu_size_8K set to 0 (disable)
> 
> It should hopefully use order-0 pages
> 
> Some drivers cant fallback to low order page allocations.
> 
> mlx4 is another example (it uses order-2 pages )

Well, now that I changed NFS to 32K buffering, I won't have the problem
anyway, so the problem is effectively fixed enough for me.
But because the default behaviour is so bad, I wanted to help fix the
defaults so that it doesn't happen to others if possible.

I haven't been following the NFS world recently, so I don't know if the code
is known broken beyond fixing, or if I did find an unusual problem that is
worth looking into.

If somehow I'm the only one, then let's not worry about it :)

Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
