From: Doug Chapman <doug.chapman@hp.com>
Subject: REGRESSION: panic on e1000 driver
Date: Wed, 30 May 2007 17:22:30 -0400
Message-ID: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: doug.chapman@hp.com, herbert@gondor.apana.org.au,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:41113 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755136AbXE3VWd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 17:22:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All,

I reported this a few weeks ago and it was fixed but it appears the
offending code was again re-submitted.  This causes a panic on HP
Integrity servers and from what I hear many other platforms using e1000
as well.

My original report was via kernel.org BZ:
http://bugzilla.kernel.org/show_bug.cgi?id=8455

I am seeing the same panic with a kernel built from today's git pull.


It was fixed by this commit:
3e1657c8ef53e1cd541cc1e420f3230dc075949b


but once again broken just yesterday by the following commit.  I have
backed just this commit out and verified I no longer panic.


commit 47313054352b879a2bc65379d55b05f48a0af7ec
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Tue May 29 15:07:31 2007 -0700

    e1000: restore netif_poll_enable call but make sure IRQs are off

    This restores the previously removed netif_poll_enable call in e1000_open.
    It's needed on all but the first call to e1000_open for a NIC as
    e1000_close always calls netif_poll_disable.

    netif_poll_enable can only be called safely if no polls have been
    scheduled.  This should be the case as long as we don't enter our IRQ
    handler.

    In order to guarantee this we explicitly disable IRQs as early as possible
    when we're probing the NIC.

    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>
    Cc: Jeff Garzik <jeff@garzik.org>
    Cc: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>




