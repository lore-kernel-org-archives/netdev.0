From: kuznet@ms2.inr.ac.ru
Subject: Re: snd_cwnd drawn and quartered
Date: Tue, 14 Jan 2003 03:12:37 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200301140012.DAA09790@sex.inr.ac.ru>
References: <20030102030858.E1363@almesberger.net>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com, chengjin@cs.caltech.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: wa@almesberger.net (Werner Almesberger)
In-Reply-To: <20030102030858.E1363@almesberger.net> from "Werner Almesberger" at Jan 2, 3 03:08:58 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I searched around but didn't spot anything. A pointer would be
> welcome, thanks !

I bring apologies for silence. I see you have already found it.

> Yes, but rate-halving is what causes in-flight to drop in the first
> place (assuming we have enough fresh data to send, of course), no ?

Of course. But draining happens when you received more ACKs than
you sent packets. When such pathalogy happens we just have to do something,
at least to understand when it happens under normal conditions.

Probably, the reason of confusion is that original rh seems to include
some bits of "lost-sensitive recovery", so cnwd really is supposed to shrink
to cwnd/2 - lost there. See? We do not make this, and the check for 1/4 really
look as an alien.

> I've put graphs of a simulation run (with and without the change) at
> http://www.almesberger.net/misc/half.eps
> http://www.almesberger.net/misc/quarter.eps

I see. Not quite understand the reason though. :-) You said something
about lost retransmissions... How much of retransmits were lost
in the simulation? Are you aware that each lost retransmission,
if we behaved honestly, would collapse cwnd to 1? :-)

Alexey
