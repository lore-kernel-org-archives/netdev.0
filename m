From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] net-bnx2x: Force link UP when the interface is in
 LOOPBACK mode
Date: Wed, 30 Jan 2013 12:24:51 +0200
Message-ID: <1359541491.26518.2.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1359510715-12099-1-git-send-email-maheshb@google.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>
To: "Mahesh Bandewar" <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1445 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753688Ab3A3KZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 05:25:57 -0500
In-Reply-To: <1359510715-12099-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-29 at 17:51 -0800, Mahesh Bandewar wrote:
> When the interface does not have carrier but when it's put into
> loopback mode (for tests), it does not make sense to not have
> the carrier. So force it!
> 

Mahesh,

What is the motivation for this change? During the test, the device is
not really functional and cannot receive traffic to the loopback, so why
would you like to indicate internally that the link is up?

> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> index 859df751345e..91af55586bbc 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> @@ -4748,6 +4748,11 @@ void bnx2x_link_status_update(struct link_params *params,
>  	vars->link_status = REG_RD(bp, params->shmem_base +
>  				   offsetof(struct shmem_region,
>  					    port_mb[port].link_status));
> +
> +	/* Force link UP in loopback mode */
> +	if (bp->link_params.loopback_mode != LOOPBACK_NONE)

The LOOPBACK_EXT requires an external loopback so we should not just
force link up indication for that kind of loopback.

> +		vars->link_status |= LINK_STATUS_LINK_UP;
> +
>  	if (bnx2x_eee_has_cap(params))
>  		vars->eee_status = REG_RD(bp, params->shmem2_base +
>  					  offsetof(struct shmem2_region,

Thanks,
Eilon
