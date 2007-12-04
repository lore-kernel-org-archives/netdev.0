From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000 driver problems
Date: Tue, 04 Dec 2007 10:05:13 -0800
Message-ID: <475596D9.10808@hp.com>
References: <20071127150700.GB4365@ics.muni.cz> <474C4A74.90705@intel.com>	<20071127173146.GG4365@ics.muni.cz> <474C5678.3060609@intel.com>	<20071127174456.GH4365@ics.muni.cz> <474C6084.9000301@intel.com>	<20071203095023.GG26573@ics.muni.cz> <47541ED0.9090808@intel.com>	<20071204153405.GG8704@ics.muni.cz>	<Pine.LNX.4.64.0712041043520.15251@tesla.psc.edu>	<20071204170827.GH8704@ics.muni.cz> <47558C0F.9000708@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Matt Mathis <mathis@psc.edu>, NetDev <netdev@vger.kernel.org>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:15102 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754556AbXLDSFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 13:05:16 -0500
In-Reply-To: <47558C0F.9000708@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is some boilerplate on autoneg which I've been using in other 
forums for a number of years when questions about autoneg vs hardcoding 
and duplex-mismatch arise:


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
