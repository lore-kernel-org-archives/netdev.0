From: Cheng Jin <chengjin@cs.caltech.edu>
Subject: Re: snd_cwnd drawn and quartered
Date: Mon, 13 Jan 2003 17:20:06 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33L0.0301131658430.26396-100000@orchestra.cs.caltech.edu>
References: <200301140012.DAA09790@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Werner Almesberger <wa@almesberger.net>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200301140012.DAA09790@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> I see. Not quite understand the reason though. :-) You said something
> about lost retransmissions... How much of retransmits were lost
> in the simulation? Are you aware that each lost retransmission,
> if we behaved honestly, would collapse cwnd to 1? :-)

Yes, I am aware of this, and when this happens, cwnd will sit @ 1 until
TCP gets out of recovery (1 retransmits per rtt).  It's debatable whether
cwnd should remain 1 for the rest of the recovery period even if really
sever congestion brings cwnd down to 1.  For example, if there are 100
pkts to be rexmitted when cwnd gets to 1, it will take at least 100 RTTs to
leave recovery.  By then, whatever network condition that causes congestion
in the first place might be long gone already, but one wouldn't know the
true state of the network with such a small cwnd.  Maybe cwnd could be
clamped at some minimum value (greater than 1) depending on ssthresh?

>From what I have observed, cwnd gets reduced to 1 mainly because of lost
retransmits.  I think the tcp_rs can show that. Linux TCP deals with a
lost retransmit by reducing retrans_out by one so in_flight ends up
becoming one less.  In tcp_cwnd_down, cwnd is always clamped at in_flight
so if many rexmits are lost (over many RTTs), cwnd gets reduced quite
often.  However, when cwnd is small, loss retransmits are not  reliable
signals for the severity of congestion, for example, when cwnd is 10,
does losing one pkt mean 10% pkts loss in the network?  Again, I am not
saying right or wrong about how cwnd changes, but it is something that
we could think about.

THanks,

Cheng
