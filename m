From: kuznet@ms2.inr.ac.ru
Subject: Re: snd_cwnd drawn and quartered
Date: Thu, 2 Jan 2003 04:38:46 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200301020138.EAA32608@sex.inr.ac.ru>
References: <20021224225040.A22201@almesberger.net>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: wa@almesberger.NET (Werner Almesberger)
In-Reply-To: <20021224225040.A22201@almesberger.net> from "Werner Almesberger" at Dec 25, 2 05:15:00 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> 	if (decr && tp->snd_cwnd > tp->snd_ssthresh/2)
> 		tp->snd_cwnd -= decr;
> 
> Unfortunately, snd_ssthresh has already been halved at this
> point, so the test actually does nothing.

It does the thing which it is supposed to do: prevents reducing cwnd below
1/4 of original one. This was proposed in one of rete-halving related drafts
with title sort of "...boundary checks...", I forgot exact title, can find
it if you are curious.


> 	if (decr && tp->snd_cwnd > tp->snd_ssthresh)

Maybe this is even correct, but I do not see why it can be essential.
cwnd falls too low not due to decrementing due to rate-halving,
but due to draining out in_flight when we are not able to keep pipe full.
Please, show. 

Alexey
