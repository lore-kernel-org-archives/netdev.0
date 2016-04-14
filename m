From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Thu, 14 Apr 2016 08:44:40 -0700
Message-ID: <1460648680.10638.47.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
	 <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160414151813.GE3715@orbyte.nwl.cc>
	 <alpine.LNX.2.00.1604141733250.27368@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1604141733250.27368@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-04-14 at 17:34 +0200, Jiri Kosina wrote:
> On Thu, 14 Apr 2016, Phil Sutter wrote:
> 
> > OTOH some qdiscs (CBQ, DRR, DSMARK, HFSC, HTB, QFQ) assign the default
> > one upon deletion instead of noop_qdisc, hence I would describe
> > the situation using the words 'inconsistent' and 'accident' rather than
> > 'expected'. :)
> 
> Exactly. I'd again like to stress the fact that this configuration works:
> 
> 	jikos:~ # tc qdisc show
> 	qdisc tbf 10: dev eth0 root refcnt 2 rate 800Mbit burst 131000b lat 1.0ms 
> 
> and this (after performing add/delete operation) doesn't:
> 
> 	jikos:~ # tc qdisc show
> 	qdisc tbf 10: dev eth0 root refcnt 2 rate 800Mbit burst 131000b lat 1.0ms 
> 
> It's hard to spot a difference (hint: there is none).

This is because some qdisc are not visible in the dump.


qdisc_list_add() uses a single list, so adding too much stuff in it
could slow down fast path (qdisc_lookup(), called from
qdisc_tree_reduce_backlog())
