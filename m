From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000 speed/duplex error
Date: Tue, 01 Aug 2006 10:03:28 -0700
Message-ID: <44CF8960.7090600@hp.com>
References: <1301563340.20060801141827@mail.ru>	<9929d2390608010420t60bd44d7o4e522c6edc0a677e@mail.gmail.com> <595776532.20060801160328@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <tarbal@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:48351 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S932442AbWHARD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 13:03:29 -0400
To: a1 <a1k@mail.ru>
In-Reply-To: <595776532.20060801160328@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I thought the common behavior is that if one side force any particular
> parameter, other side should "sense" that and go to that mode too.

Nope.  That is a common misconception and perhaps the source of many 
duplex mismatch problems today.  Here is some boilerplate I bring-out 
from time to time that may be of help:

$ cat usenet_replies/duplex
How 100Base-T Autoneg is supposed to work:

When both sides of the link are set to autoneg, they will "negotiate"
the duplex setting and select full-duplex if both sides can do
full-duplex.

If one side is hardcoded and not using autoneg, the autoneg process
will "fail" and the side trying to autoneg is required by spec to use
half-duplex mode.

If one side is using half-duplex, and the other is using full-duplex,
sorrow and woe is the usual result.

So, the following table shows what will happen given various settings
on each side:

                  Auto       Half       Full

    Auto        Happiness   Lucky      Sorrow

    Half        Lucky       Happiness  Sorrow

    Full        Sorrow      Sorrow     Happiness

Happiness means that there is a good shot of everything going well.
Lucky means that things will likely go well, but not because you did
anything correctly :) Sorrow means that there _will_ be a duplex
mis-match.

When there is a duplex mismatch, on the side running half-duplex you
will see various errors and probably a number of _LATE_ collisions
("normal" collisions don't count here).  On the side running
full-duplex you will see things like FCS errors.  Note that those
errors are not necessarily conclusive, they are simply indicators.

Further, it is important to keep in mind that a "clean" ping (or the
like - eg "linkloop" or default netperf TCP_RR) test result is
inconclusive here - a duplex mismatch causes lost traffic _only_ when
both sides of the link try to speak at the same time. A typical ping
test, being synchronous, one at a time request/response, never tries
to have both sides talking at the same time.

Finally, when/if you migrate to 1000Base-T, everything has to be set
to auto-neg anyway.

rick jones
