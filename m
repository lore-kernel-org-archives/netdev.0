From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Sat, 28 Jul 2007 08:27:18 -0700
Message-ID: <ada1wesy2eh.fsf@cisco.com>
References: <20070725.013154.34764933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:18559 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbXG1P12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2007 11:27:28 -0400
In-Reply-To: <20070725.013154.34764933.davem@davemloft.net> (David Miller's message of "Wed, 25 Jul 2007 01:31:54 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Most drivers are in good shape, although some still have very
 > questionable netif_rx_complete() handling, in that racy area that
 > Rusty and myself were discussing today.
 > 
 > My inclination is to wrap those sequences around with an IRQ
 > safe spinlock to fix the race provably, and then if driver
 > authors want to optimize that away with techniques like those
 > that tg3, bnx2, sky2, skge et al. use, that's fine but can
 > be done later.

Ouch... that extra lock seems pretty expensive.  Also I'm having a
hard time understanding how the techniques you're alluding to apply to
devices that may miss events when enabling interrupts; the drivers you
mention all seem to be for devices that didn't have the race and
didn't use netif_rx_reschedule() in the old NAPI world.  Can you
provide a little more detail on how the lock could be optimized away?

Thanks,
  Roland
