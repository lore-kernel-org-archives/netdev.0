From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH net-next v3] bnxt_en: New Broadcom ethernet driver.
Date: Mon, 19 Oct 2015 15:07:46 -0700
Message-ID: <1445292466.7588.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
	 <20151018222150.427d5311@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <prashant@broadcom.com>,
	<eddie.wai@broadcom.com>, <huangjw@broadcom.com>,
	<netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:31562 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbbJSWJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 18:09:16 -0400
In-Reply-To: <20151018222150.427d5311@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-10-18 at 22:21 -0700, Stephen Hemminger wrote: 
> On Sat, 17 Oct 2015 00:21:44 -0400
> Michael Chan <mchan@broadcom.com> wrote:
> 
> > +static inline u32 bnxt_tx_avail(struct bnxt *bp, struct bnxt_tx_ring_info *txr)
> > +{
> > +	/* Tell compiler to fetch tx indices from memory. */
> > +	barrier();
> 
> Actually, you are telling compiler not to reorder. Which may not
> be sufficient on some platforms. 

Only a compiler barrier is needed here to prevent the compiler from
optimizing out the memory access of tx_prod and tx_cons, in case it
thinks that it has those values in some registers.

> 
> 
> > +	return bp->tx_ring_size -
> > +		((txr->tx_prod - txr->tx_cons) & bp->tx_ring_mask);
> > +}
