From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] gianfar: Wait for both RX and TX to stop
Date: Mon, 19 Apr 2010 23:44:49 -0500
Message-ID: <68CA249E-C6E9-43EA-A132-C48DB9E2384D@kernel.crashing.org>
References: <1271632401-2472-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>,
	Andy Fleming <afleming@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:32792 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753339Ab0DTEoy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 00:44:54 -0400
In-Reply-To: <1271632401-2472-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 18, 2010, at 6:13 PM, Andy Fleming wrote:

> When gracefully stopping the controller, the driver was continuing if
> *either* RX or TX had stopped.  We need to wait for both, or the
> controller could get into an invalid state.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
> drivers/net/gianfar.c |    5 +++--
> 1 files changed, 3 insertions(+), 2 deletions(-)

Acked-by: Kumar Gala <galak@kernel.crashing.org>

(please pick this up for 2.6.34, fixes an annoying bug).

- k
 
> 
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index 032073d..6038397 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -1571,8 +1571,9 @@ static void gfar_halt_nodisable(struct net_device *dev)
> 		tempval |= (DMACTRL_GRS | DMACTRL_GTS);
> 		gfar_write(&regs->dmactrl, tempval);
> 
> -		while (!(gfar_read(&regs->ievent) &
> -			 (IEVENT_GRSC | IEVENT_GTSC)))
> +		while ((gfar_read(&regs->ievent) &
> +			 (IEVENT_GRSC | IEVENT_GTSC)) !=
> +			 (IEVENT_GRSC | IEVENT_GTSC))
> 			cpu_relax();
> 	}
> }
> -- 
> 1.6.5.2.g6ff9a
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

