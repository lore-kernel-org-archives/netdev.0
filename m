From: Cheng Jin <chengjin@cs.caltech.edu>
Subject: Re: snd_cwnd drawn and quartered
Date: Mon, 13 Jan 2003 17:58:07 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33L0.0301131752020.26396-100000@orchestra.cs.caltech.edu>
References: <200301140146.EAA10411@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "wa@almesberger.net" <wa@almesberger.net>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200301140146.EAA10411@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> > Yes, I am aware of this, and when this happens, cwnd will sit @ 1 until
> > TCP gets out of recovery (1 retransmits per rtt).  It's debatable
>
> Nothing to debate, really. Following specs lost retransmission must trigger
> RTO timeout with sunsubsequent slow start starting from 1.

I don't always see time-out+slow-start in this case.  I have seen
TCP staying in recovery for a very long time with cwnd=1.  I think Linux
TCP has various detection mechanisms for lost rexmit so time-out doesn't
always happen.  I think there is lost rexmit detection code at the end of
tcp_sacktag_write_queue.

> We are _more_ liberal when SACKs are on, this really can be argued
> and I am ready to defend the liberal values. :-) But when we cannot
> detect loss opf retransmission, we have to return to standard go-back-n
> behaviour.

Yes, Linux does indeed do more aggressive lost detection than what's in
the spec.  I am fine with that.

> Not a big deal. You have to wait the same 100 RTTs at start of each connection,
> even though initial slow start _assumes_ that no congestion is present.
> So, when you experienced real congestion, slow start is really fair. :-)

I am not sure what you mean here, slow start takes much faster to
transmit 100 pkts than 100 RTTs.  Maybe there is a misunderstanding here,
when cwnd=1 in congestion recovery, it will stay at 1 until it exits
recovery unless some packet times out first.

> Not less than 10% of loss. Maybe, more, but you were lucky and your
> packets percolated through deadly congested router. :-)
> It is basic assumption of cwnd avoidance: each loss is considered
> as loss due to congestion.

Certainly. It's difficult to know what the right cwnd should be when this
happens, and a conservative approach may be the best one to take.  I am
just curious if people can come up with better ways to set cwnd.

Cheng
