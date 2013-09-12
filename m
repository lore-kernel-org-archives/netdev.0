From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 linux-next] hrtimer: Add notifier when clock_was_set
 was called
Date: Thu, 12 Sep 2013 13:32:52 -0400 (EDT)
Message-ID: <20130912.133252.425268707009916773.davem@davemloft.net>
References: <alpine.DEB.2.02.1309121441420.4089@ionos.tec.linutronix.de>
	<20130912134409.GB21212@gondor.apana.org.au>
	<alpine.DEB.2.02.1309121636010.4089@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, fan.du@windriver.com,
	steffen.klassert@secunet.com, dborkman@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755272Ab3ILRc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 13:32:58 -0400
In-Reply-To: <alpine.DEB.2.02.1309121636010.4089@ionos.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 12 Sep 2013 16:43:37 +0200 (CEST)

> So what about going back to timer_list timers and simply utilize
> register_pm_notifier(), which will tell you that the system resumed?

The thing to understand is that there are two timeouts for an IPSEC
rule, a soft and a hard timeout.

There is a gap between these two exactly so that we can negotiate a
new encapsulation with the IPSEC gateway before communication ceases
to be possible over the IPSEC protected path.

So the idea is that the soft timeout triggers the re-negotiation,
and after a hard timeout the IPSEC path is no longer usable and
all communication will fail.

Simply triggering a re-negoation after every suspend/resume makes
no sense at all.  Spurious re-negotiations are undesirable.

What we want are real timers.  We want that rather than a "we
suspended so just assume all timers expired" event which is not very
useful for this kind of application.
