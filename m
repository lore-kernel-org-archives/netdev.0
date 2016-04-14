From: Jiri Kosina <jikos@kernel.org>
Subject: Re: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Thu, 14 Apr 2016 17:34:52 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1604141733250.27368@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm> <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com> <20160414151813.GE3715@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160414151813.GE3715@orbyte.nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Apr 2016, Phil Sutter wrote:

> OTOH some qdiscs (CBQ, DRR, DSMARK, HFSC, HTB, QFQ) assign the default
> one upon deletion instead of noop_qdisc, hence I would describe
> the situation using the words 'inconsistent' and 'accident' rather than
> 'expected'. :)

Exactly. I'd again like to stress the fact that this configuration works:

	jikos:~ # tc qdisc show
	qdisc tbf 10: dev eth0 root refcnt 2 rate 800Mbit burst 131000b lat 1.0ms 

and this (after performing add/delete operation) doesn't:

	jikos:~ # tc qdisc show
	qdisc tbf 10: dev eth0 root refcnt 2 rate 800Mbit burst 131000b lat 1.0ms 

It's hard to spot a difference (hint: there is none).

Thanks,

-- 
Jiri Kosina
SUSE Labs
