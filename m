From: Werner Almesberger <wa@almesberger.net>
Subject: Re: snd_cwnd drawn and quartered
Date: Thu, 2 Jan 2003 03:08:58 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030102030858.E1363@almesberger.net>
References: <20021224225040.A22201@almesberger.net> <200301020138.EAA32608@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, chengjin@cs.caltech.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200301020138.EAA32608@sex.inr.ac.ru>; from kuznet@ms2.inr.ac.ru on Thu, Jan 02, 2003 at 04:38:46AM +0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> It does the thing which it is supposed to do: prevents reducing cwnd below
> 1/4 of original one.

Okay, this it does. I guess the only case where this would make a
difference is if your network duplicates packets.

> This was proposed in one of rete-halving related drafts
> with title sort of "...boundary checks...", I forgot exact title, can find
> it if you are curious.

I searched around but didn't spot anything. A pointer would be
welcome, thanks !

> Maybe this is even correct, but I do not see why it can be essential.
> cwnd falls too low not due to decrementing due to rate-halving,
> but due to draining out in_flight when we are not able to keep pipe full.

Yes, but rate-halving is what causes in-flight to drop in the first
place (assuming we have enough fresh data to send, of course), no ?

> Please, show. 

I've put graphs of a simulation run (with and without the change) at
http://www.almesberger.net/misc/half.eps
http://www.almesberger.net/misc/quarter.eps

Y-axis is in segments, x-axis is in some arbitrary time unit, RTT is
one initial cwnd (100 packets), path is asymmetric with zero-delay
and loss-less backward channel. (While unusual, this shouldn't
actually affect what TCP does in recovery.) Losses happen right
before the packet hits the receiver.

I've also asked Cheng if he can send you a copy of his simulator.

Thanks,
- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
