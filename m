From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qede: Fix Tx timeout due to xmit_more
Date: Thu, 18 Aug 2016 21:13:37 -0700 (PDT)
Message-ID: <20160818.211337.397326041714337261.davem@davemloft.net>
References: <1471362018-12152-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41861 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752244AbcHSEOI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 00:14:08 -0400
In-Reply-To: <1471362018-12152-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Tue, 16 Aug 2016 18:40:18 +0300

> Driver uses netif_tx_queue_stopped() to make sure the xmit_more
> indication will be honored, but that only checks for DRV_XOFF.
> 
> At the same time, it's possible that during transmission the DQL will
> close the transmission queue with STACK_XOFF indication.
> In re-configuration flows, when the threshold is relatively low, it's
> possible that the device has no pending tranmissions, and during
> tranmission the driver would miss doorbelling the HW.
> Since there are no pending transmission, there will never be a Tx
> completion [and thus the DQL would not remove the STACK_XOFF indication],
> eventually causing the Tx queue to timeout.
> 
> While we're at it - also doorbell in case driver has to close the
> transmission queue on its own [although this one is less important -
> if the ring is full, we're bound to receive completion eventually,
> which means the doorbell would only be postponed and not indefinetly
> blocked].
> 
> Fixes: 312e06761c99 ("qede: Utilize xmit_more")
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied, thanks.

> Do notice that we have pending patch intended for 'net-next'
> ("qede: Add support for per-queue stats") that might cause a merge
> conflict with this one - although it should be trivial to resolve.

Ok.
