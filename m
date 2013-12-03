From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Wed, 4 Dec 2013 00:49:20 +0100
Message-ID: <20131203234919.GA27943@order.stressinduktion.org>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com> <1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com> <20131203.165034.1085515763685633822.davem@davemloft.net> <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com> <CAJZOPZKg0UMmdknLJCgNo3cTFmszASLPYYJnB7g9h4M64xMy8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57435 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755696Ab3LCXtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 18:49:21 -0500
Content-Disposition: inline
In-Reply-To: <CAJZOPZKg0UMmdknLJCgNo3cTFmszASLPYYJnB7g9h4M64xMy8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 04, 2013 at 01:30:09AM +0200, Or Gerlitz wrote:
> On Wed, Dec 4, 2013 at 1:10 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> > On Tue, Dec 3, 2013 at 11:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> On Tue, 2013-12-03 at 16:50 -0500, David Miller wrote:
> >>
> >>> At this point I would use drop monitor to figure out in what context
> >>> packets are being dropped on the floor.  There are scripts provided
> >>> with the perf tool to utilize it.
> >>
> >> Most easy way is to do :
> >>
> >> perf record -e skb:kfree_skb -a -g sleep 10
> >> perf report
> >
> > $ ./perf record -e skb:kfree_skb -g -a sleep 10
> > $ ./perf report -i perf.data
> >
> >
> > Samples: 883K of event 'skb:kfree_skb', Event count (approx.): 883406
> > +  97.13%          swapper  [kernel.kallsyms]  [k] net_tx_action
> > +   1.53%            iperf  [kernel.kallsyms]  [k] net_tx_action
> > +   1.03%             perf  [kernel.kallsyms]  [k] net_tx_action
> > +   0.27%      ksoftirqd/7  [kernel.kallsyms]  [k] net_tx_action
> > +   0.03%      kworker/7:1  [kernel.kallsyms]  [k] net_tx_action
> > +   0.00%          rpcbind  [kernel.kallsyms]  [k] net_tx_action
> > +   0.00%          swapper  [kernel.kallsyms]  [k] kfree_skb
> > +   0.00%            sleep  [kernel.kallsyms]  [k] net_tx_action
> > +   0.00%  hald-addon-acpi  [kernel.kallsyms]  [k] kfree_skb
> > +   0.00%            iperf  [kernel.kallsyms]  [k] kfree_skb
> > +   0.00%             perf  [kernel.kallsyms]  [k] kfree_skb
> 
> I added proper sorting (thanks Rick), here's the passive side report

Btw. the nice helper for the dropwatch is "perf script net_dropmonitor".

Greetings,

  Hannes
