From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 rx_missed increasing in bursts (regression)
Date: Tue, 8 Jan 2013 23:58:33 +0100
Message-ID: <20130108225833.GA4193@electric-eye.fr.zoreil.com>
References: <20130108102814.7abe8c08@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51013 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551Ab3AHX0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 18:26:31 -0500
Content-Disposition: inline
In-Reply-To: <20130108102814.7abe8c08@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Teras <timo.teras@iki.fi> :
[...]
> My current hypothesis is that due to high softirq and recent(ish)
> commit da78dbf "r8169: remove work from irq handler" moving more work
> to softirq makes the receive path now suffer from latency from getting
> irq to reading packets from the NIC on these boxes. And that at times
> the rx fifo can get full causing a missed packet or so.

This hypothesis won't explain the regression in 3.3.8 since 3.3.x does
not include commit da78dbf.

Do you notice any netdev watchdog message in dmesg ?

'perf top' may exhibit something unusual too.

> This might be further escalated by the bug fixed in commit 7dbb491
> "r8169: avoid NAPI scheduling delay" (which is not present in -stable
> trees).

Right, it would had been worth adding to -stable.

However it only 1) is a problem for 3.4.x (fixed in 3.5) and 2) triggers
when returning from the slow work thread - which should not be used much.

[...]
> So would it be sensible to do something like:
> -#define NUM_RX_DESC    256     /* Number of Rx descriptor registers */
> +#define NUM_RX_DESC    512     /* Number of Rx descriptor registers */

You can try it but it may actually increase the amount of heavy work done
in softirq.

> And cherry-picking the commit 7dbb491? Perhaps this could be pushed to
> the -stable queues too.

3.4.x at most.

-- 
Ueimor
