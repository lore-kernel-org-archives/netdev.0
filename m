From: kuznet@ms2.inr.ac.ru
Subject: Re: snd_cwnd drawn and quartered
Date: Tue, 14 Jan 2003 04:46:49 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200301140146.EAA10411@sex.inr.ac.ru>
References: <Pine.LNX.4.33L0.0301131658430.26396-100000@orchestra.cs.caltech.edu>
Mime-Version: 1.0
Cc: wa@almesberger.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chengjin@cs.caltech.edu (Cheng Jin)
In-Reply-To: <Pine.LNX.4.33L0.0301131658430.26396-100000@orchestra.cs.caltech.edu> from "Cheng Jin" at Jan 13, 3 05:20:06 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Yes, I am aware of this, and when this happens, cwnd will sit @ 1 until
> TCP gets out of recovery (1 retransmits per rtt).  It's debatable

Nothing to debate, really. Following specs lost retransmission must trigger
RTO timeout with sunsubsequent slow start starting from 1.

We are _more_ liberal when SACKs are on, this really can be argued
and I am ready to defend the liberal values. :-) But when we cannot
detect loss opf retransmission, we have to return to standard go-back-n
behaviour.

> pkts to be rexmitted when cwnd gets to 1, it will take at least 100 RTTs to

Not a big deal. You have to wait the same 100 RTTs at start of each connection,
even though initial slow start _assumes_ that no congestion is present.
So, when you experienced real congestion, slow start is really fair. :-)


>      In tcp_cwnd_down, cwnd is always clamped at in_flight
> so if many rexmits are lost (over many RTTs), cwnd gets reduced quite
> often.

It is (half of) loss-sensitive recovery. Luckily, we are not mad enough
to shrink ssthresh as well. But imagine, month ago I had long boring
argument with a guy who insisted that ssthresh must be shrinken too,
otherwise "cwnd grows too fast". :-)


> does losing one pkt mean 10% pkts loss in the network?

Not less than 10% of loss. Maybe, more, but you were lucky and your
packets percolated through deadly congested router. :-)
It is basic assumption of cwnd avoidance: each loss is considered
as loss due to congestion.

Alexey
