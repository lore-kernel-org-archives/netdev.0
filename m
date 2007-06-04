From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2/5][BNX2]: Add missing wait in bnx2_init_5709_context().
Date: Mon, 4 Jun 2007 19:39:40 -0400
Message-ID: <20070604233940.GB31462@havoc.gtf.org>
References: <1181001635.5275.13.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, andy@greyhouse.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:38549 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754120AbXFDXjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 19:39:40 -0400
Content-Disposition: inline
In-Reply-To: <1181001635.5275.13.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 04, 2007 at 05:00:35PM -0700, Michael Chan wrote:
> [BNX2]: Add missing wait in bnx2_init_5709_context().
> 
> For correctness, we need to wait for the MEM_INIT bit to be cleared
> in the BNX2_CTX_COMMAND register before proceeding.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 5d69e5b..daa62d9 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -1778,6 +1778,12 @@ bnx2_init_5709_context(struct bnx2 *bp)
>  	val = BNX2_CTX_COMMAND_ENABLED | BNX2_CTX_COMMAND_MEM_INIT | (1 << 12);
>  	val |= (BCM_PAGE_BITS - 8) << 16;
>  	REG_WR(bp, BNX2_CTX_COMMAND, val);
> +	for (i = 0; i < 10; i++) {
> +		val = REG_RD(bp, BNX2_CTX_COMMAND);
> +		if (!(val & BNX2_CTX_COMMAND_MEM_INIT))
> +			break;
> +		udelay(2);
> +	}
>  	for (i = 0; i < bp->ctx_pages; i++) {
>  		int j;

If the bit does not clear after 10 loops, it seems to me you should
complain or somehow otherwise make note of the failure.

	Jeff



