From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on
 low-end broads.
Date: Wed, 28 Dec 2011 13:34:50 -0500 (EST)
Message-ID: <20111228.133450.479385013770977594.davem@davemloft.net>
References: <1325092423.2327.70.camel@deadeye>
	<CACPM=kX2hcGt3XXDJkCAcOjv=5oqSHChhhphUAyRhR_PsNFEEQ@mail.gmail.com>
	<20111228101710.51c4893f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gurligebis@gentoo.org, bhutchings@solarflare.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rl@hellgate.ch
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56668 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066Ab1L1SfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 13:35:04 -0500
In-Reply-To: <20111228101710.51c4893f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 28 Dec 2011 10:17:10 -0800

> Looks like the hardware isn't really disabling interrupts correctly to support
> NAPI. NAPI is supposed to be friendly and under load the work should move to
> ksoftirqd. I suspect the IRQ management in this driver is borked.
> There is some stupid spin loops in the IRQ handler that happen when looking for
> Tx IRQ. I would run with debug set  and see if this is triggering.

This could be simply a side effect of the fact that via-rhine only does
RX work in it's NAPI handler.

If all the work (or at least both TX and RX) were moved into the NAPI
handler, it'd probably be easier to properly shut off all IRQs during
NAPI processing, and thus avoid the high CPU load in the IRQ handler
being seen here.

This "shut off only some interrupts" scheme is just asking for trouble.
