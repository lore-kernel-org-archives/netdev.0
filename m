From: kuznet@ms2.inr.ac.ru
Subject: Re: snd_cwnd drawn and quartered
Date: Tue, 14 Jan 2003 09:14:36 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200301140614.JAA10804@sex.inr.ac.ru>
References: <20030114022509.P1516@almesberger.net>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com, chengjin@cs.caltech.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: wa@almesberger.net (Werner Almesberger)
In-Reply-To: <20030114022509.P1516@almesberger.net> from "Werner Almesberger" at Jan 14, 3 02:25:09 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> > Losses in the same window must not result in multiplicative collapse
> > of cwnd or extension of recovery period. If they do, we are really buggy.
> 
> Oh, according to NewReno, extending the recovery period is just fine.

Sorry, it is just nonsense in newreno, it is that high_seq makes.
Well, and this is surely not fine, losses in several consecutive
windows must result in multiplicative reduction of cwnd.


> Yes yes, we do ... that's what NewReno is all about. Let's say you
> lose the 0th and the 99th segment (with cwnd = 100). You'll detect
> the first loss at t = 100, and enter recovery. You leave recovery
> once snd_nxt (stored in high_seq) at that time has been ack'ed. So
> this is 100. At time t=199, we find out about the loss of the 99th
> segment, and retransmit. This gets ack'ed at time t=299. So it's
> only then when we leave recovery.

I do not understand, what you has just said. You cant discover
loss of 99th segment _after_ 100th was happily ACKed. :-) :-)


> draft-ratehalving distinguishes the adjustement interval and the
> repair interval. The latter lasts until we've fixed all losses,
> while the former should indeed not exceed one RTT. It's this
> limitation that's missing in Linux.

But thit does not matter because it handles opposite case, when cwnd
was not reduced enough for one RTT, so rh falls to hold state
to decrease cwnd smoothly. It is just an unnecessary complication
to my opinion. Did I get this wrong?

Picture, Werner! What does happen on picture quarter.eps???? That's question.

Alexey
