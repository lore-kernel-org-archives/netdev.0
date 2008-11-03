From: Alex Chiang <achiang@hp.com>
Subject: Re: [PATCH 1/4]bnx2x: Removing the PMF indication when unloading
Date: Mon, 3 Nov 2008 15:07:43 -0700
Message-ID: <20081103220743.GA16427@ldl.fc.hp.com>
References: <1225728673.14568.10.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:43213 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992AbYKCWHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 17:07:44 -0500
Content-Disposition: inline
In-Reply-To: <1225728673.14568.10.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eilon Greenstein <eilong@broadcom.com>:
> 
> When the PMF flag is set, the driver can access the HW freely. When the
> driver is unloaded, it should not access the HW. The problem caused fatal
> errors when "ethtool -i" was called after the calling instance was unloaded
> and another instance was already loaded

Without this patch, a BCM57711E will cause an MCA on a BL870c
within minutes of starting a test that pushes traffic over the
ports while in multi-function mode (100% of the time within 10
minutes).

I've been testing this patch for the last two hours or so and it
seems to fix the problem.

Tested-by: Alex Chiang <achiang@hp.com>

> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  drivers/net/bnx2x_main.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index fce7451..61152e1 100644
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -6481,6 +6481,7 @@ load_int_disable:
>         bnx2x_free_irq(bp);
>  load_error:
>         bnx2x_free_mem(bp);
> +       bp->port.pmf = 0;
> 
>         /* TBD we really need to reset the chip
>            if we want to recover from this */
> @@ -6791,6 +6792,7 @@ unload_error:
>         /* Report UNLOAD_DONE to MCP */
>         if (!BP_NOMCP(bp))
>                 bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
> +       bp->port.pmf = 0;
> 
>         /* Free SKBs, SGEs, TPA pool and driver internals */
>         bnx2x_free_skbs(bp);
> --
> 1.5.4.3
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
