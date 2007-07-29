From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Sat, 28 Jul 2007 22:32:06 -0700 (PDT)
Message-ID: <20070728.223206.112621083.davem@davemloft.net>
References: <20070725.013154.34764933.davem@davemloft.net>
	<ada1wesy2eh.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59833
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752039AbXG2FcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 01:32:07 -0400
In-Reply-To: <ada1wesy2eh.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Sat, 28 Jul 2007 08:27:18 -0700

>  > Most drivers are in good shape, although some still have very
>  > questionable netif_rx_complete() handling, in that racy area that
>  > Rusty and myself were discussing today.
>  > 
>  > My inclination is to wrap those sequences around with an IRQ
>  > safe spinlock to fix the race provably, and then if driver
>  > authors want to optimize that away with techniques like those
>  > that tg3, bnx2, sky2, skge et al. use, that's fine but can
>  > be done later.
> 
> Ouch... that extra lock seems pretty expensive.  Also I'm having a
> hard time understanding how the techniques you're alluding to apply to
> devices that may miss events when enabling interrupts; the drivers you
> mention all seem to be for devices that didn't have the race and
> didn't use netif_rx_reschedule() in the old NAPI world.  Can you
> provide a little more detail on how the lock could be optimized away?

If you have a means in the device (like tg3, bnx2, e1000, and a score
of others do) to force the device to trigger a HW interrupt, that's
what you do if you detect that events are pending after re-enabling
interrupt in the ->poll() handler.

Frankly I don't think the lock is a big deal and you need something
like it anyways typically.
