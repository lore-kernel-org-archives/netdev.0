From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Fri, 5 Nov 2004 20:43:03 +0100
Message-ID: <20041105194303.GA12289@postel.suug.ch>
References: <418B4C7C.8000402@crocom.com.pl> <20041105115430.GP19714@rei.reeler.org> <418B4C7C.8000402@crocom.com.pl> <20041105141640.GQ19714@rei.reeler.org> <418BA66A.60804@trash.net> <20041105163951.GY12289@postel.suug.ch> <418BB7D2.6060908@trash.net> <20041105175812.GZ12289@postel.suug.ch> <418BC40E.8080402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, spam@crocom.com.pl,
        kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <418BC40E.8080402@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <418BC40E.8080402@trash.net> 2004-11-05 19:18
> Yes, but there doesn't seem to be a path where this is true.

I will double check this, there must be something wrong with
one of the callers to qdisc_destroy since it's the only way
entries can be removed from qdisc_list and otherwise the oops wouldn't
show up with the POISON1.

> __qdisc_destroy is called from a rcu-callback, not directly from
> qdisc_destroy.

You're indeed right, I haven't noticed queue_lock being a softirq
spinlock, stupid me.

So to have qdisc_destroy be reliable we should either make sure
dev->queue_lock is held for every call or switch to list_del_rcu.
since qdisc_destroy might be called from bh context.

I will audit all paths, I'm pretty sure the reported oops is
somehow related to this.
