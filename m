From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Improved network performance by balancing Rx against
 other work
Date: Sun, 21 Mar 2010 20:21:59 -0700 (PDT)
Message-ID: <20100321.202159.235697842.davem@davemloft.net>
References: <87tysfu05d.wl%peterc@chubb.wattle.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peter.chubb@nicta.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55381
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753726Ab0CVDVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 23:21:36 -0400
In-Reply-To: <87tysfu05d.wl%peterc@chubb.wattle.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Chubb <peter.chubb@nicta.com.au>
Date: Wed, 17 Mar 2010 13:55:58 +1100

> The general approach is to restrict the work done in the Rx-side
> processing to just 32 or so packets at a time then call
> sys_sched_yield() to allow other system processing to get a look in.
> Currently, NAPI processing happens in soft IRQ context, and much of it
> with interrupts off.

This is a deficiency in the locking done by such drivers.  Many
drivers lock properly and do not disable hardware interrupts during
NAPI processing.  Not only is this more efficient, it also makes
the driver more profilable.  For example, on cpus with only timer
based profiling everything done in NAPI context can be seen.

> In addition, because so much runs with interrupts disabled,
> real-time performance sucks.

Please respin your analysis to be done with a sane driver, one that
does not disable hardware interrupts.  Doing so is a driver, rather
than a fundamental, issue of NAPI.

Avoiding hardware interrupt disabling also has another huge benefit,
it means that the transmit path of the driver need not disable
hardware interrupts either since that already runs in software
interrupt disabled context.

Your analysis was essentially done with broken driver(s), so I think
I can stop reading here.
