From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 7/11][TG3]: Eliminate the TG3_FLAG_5701_REG_WRITE_BUG flag.
Date: Sat, 5 May 2007 10:46:12 +0100
Message-ID: <20070505094612.GB9592@infradead.org>
References: <1178326457.4859.23.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:46516 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934084AbXEERZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 13:25:54 -0400
Content-Disposition: inline
In-Reply-To: <1178326457.4859.23.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 05:54:17PM -0700, Michael Chan wrote:
> +	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
> +		 ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
> +		  tp->pci_chip_rev_id == CHIPREV_ID_5750_A0)) {
> +		/* Back to back register writes can cause problems on this chip,
> +		 * the workaround is to read back all reg writes except those to
> +		 * mailbox regs.  See tg3_write_indirect_reg32().
> +		 *
> +		 * PCI Express 5750_A0 rev chips need this workaround too.
> +		 */
>  		tp->write32 = tg3_write_flush_reg32;

This comment is a little odd now.  What about

		/*
		 * Back to back register writes can cause problems on these
		 * chips, the workaround is to read back all reg writes
		 * except those to mailbox regs.
		 *
		 * See tg3_write_indirect_reg32().
		 */

instead?

