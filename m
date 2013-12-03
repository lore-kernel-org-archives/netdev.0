From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 3 Dec 2013 23:30:53 +0100
Message-ID: <20131203223053.GA26282@order.stressinduktion.org>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com> <1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com> <20131203.165034.1085515763685633822.davem@davemloft.net> <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZL2dq2c=5tmx+2VHX9eD1gG=pqyiQcvCvCGT+_3SDFKkQ@mail.gmail.com>
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
Received: from order.stressinduktion.org ([87.106.68.36]:57226 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755204Ab3LCWay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 17:30:54 -0500
Content-Disposition: inline
In-Reply-To: <CAJZOPZL2dq2c=5tmx+2VHX9eD1gG=pqyiQcvCvCGT+_3SDFKkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 04, 2013 at 12:22:08AM +0200, Or Gerlitz wrote:
> On Tue, Dec 3, 2013 at 11:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2013-12-03 at 16:50 -0500, David Miller wrote:
> >
> >> At this point I would use drop monitor to figure out in what context
> >> packets are being dropped on the floor.  There are scripts provided
> >> with the perf tool to utilize it.
> >
> > Most easy way is to do :
> >
> > perf record -e skb:kfree_skb -a -g sleep 10
> 
> some typo here? I tried the perf tool that comes with the net git
> 
> ./perf record -e skb:kfree_skb -a -g sleep 10
> invalid or unsupported event: 'skb:kfree_skb'
> Run 'perf list' for a list of valid events
> 
>  usage: perf record [<options>] [<command>]
>     or: perf record [<options>] -- <command> [<options>]
> 
>     -e, --event <event>   event selector. use 'perf list' to list
> available events

-g takes an optional argument. Reorder the arguments:

perf record -e skb:kfree_skb -g -a sleep 10
