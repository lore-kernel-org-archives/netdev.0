From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 8139cp: set ring address after enabling C+ mode
Date: Wed, 21 Nov 2012 21:40:45 +0100
Message-ID: <20121121204045.GA17627@electric-eye.fr.zoreil.com>
References: <20120602235020.2C0A57C006C@ra.kernel.org> <1353517042.26346.130.camel@shinybook.infradead.org> <50AD1972.5080403@pobox.com> <1353529639.26346.164.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Jason Wang <jasowang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>, gilboad@gmail.com
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39211 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964825Ab2KUVFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 16:05:19 -0500
Content-Disposition: inline
In-Reply-To: <1353529639.26346.164.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
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
> Cc: stable@kernel.org [3.5+]
> 
> ---
> How about this? I'm still somewhat confused about when it actually
> *does* start doing DMA, given what the datasheet says.

Straight to -stable ?

Afaik nobody complained from the original (pre b01af457) problem on
real hardware.

May be someone @realtek (hi Hayes) can give an explanation regarding
the CpCmd, RingAddr, Cmd init sequence and the start of DMA.

-- 
Ueimor
