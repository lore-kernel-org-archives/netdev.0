From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139cp: set ring address after enabling C+ mode
Date: Sun, 25 Nov 2012 15:54:57 -0500 (EST)
Message-ID: <20121125.155457.1039099162410338935.davem@davemloft.net>
References: <1353517042.26346.130.camel@shinybook.infradead.org>
	<50AD1972.5080403@pobox.com>
	<1353529639.26346.164.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, jasowang@redhat.com, netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387Ab2KYUzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 15:55:08 -0500
In-Reply-To: <1353529639.26346.164.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 21 Nov 2012 20:27:19 +0000

> This fixes (for me) a regression introduced by commit b01af457 ("8139cp:
> set ring address before enabling receiver"). That commit configured the
> descriptor ring addresses earlier in the initialisation sequence, in
> order to avoid the possibility of triggering stray DMA before the
> correct address had been set up.
> 
> Unfortunately, it seems that the hardware will scribble garbage into the
> TxRingAddr registers when we enable "plus mode" Tx in the CpCmd
> register. Observed on a Traverse Geos router board.
> 
> To deal with this, while not reintroducing the problem which led to the
> original commit, we augment cp_start_hw() to write to the CpCmd register
> *first*, then set the descriptor ring addresses, and then finally to
> enable Rx and Tx in the original 8139 Cmd register. The datasheet
> actually indicates that we should enable Tx/Rx in the Cmd register
> *before* configuring the descriptor addresses, but that would appear to
> re-introduce the problem that the offending commit b01af457 was trying
> to solve. And this variant appears to work fine on real hardware.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Applied to net-next.
