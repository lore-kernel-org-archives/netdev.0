From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Sat, 6 Nov 2004 02:59:31 +0100
Message-ID: <20041106015931.GA28715@postel.suug.ch>
References: <418B4C7C.8000402@crocom.com.pl> <20041105141640.GQ19714@rei.reeler.org> <418BA66A.60804@trash.net> <20041105163951.GY12289@postel.suug.ch> <418BB7D2.6060908@trash.net> <20041105175812.GZ12289@postel.suug.ch> <418BC40E.8080402@trash.net> <20041105194303.GA12289@postel.suug.ch> <20041106011843.GI12289@postel.suug.ch> <418C2D40.9020300@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, spam@crocom.com.pl,
        kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <418C2D40.9020300@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <418C2D40.9020300@trash.net> 2004-11-06 02:47
> Nice work, I was really beginning to wonder. There's not that
> much that touches qdisc_list :)

Which might have been the problem, I've been focusing on this for
hours overlooking the obvious. The bug report was very well done,
maybe too good so I was at the root of the problem too fast. ;->

> The __qdisc_destroy rcu-callback is called in softirq context, when
> destroying a classful qdisc the qdisc destroy function might call
> qdisc_destroy again for an inner class.

Ahh... of course. I was looking through all callers of destroy multiple
times but somehow I managed to overlook the one in __qdisc_destroy
over and over.  Thanks!

> >I guess I'm missing that little bit of experience but it would
> >help to use _rcu list variantes, would it?
> >
> Yes. Are you going to send a patch ?

Sure, tomorrow, if nobody preempts. I need some rest.
