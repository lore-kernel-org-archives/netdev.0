From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 07/16] sfc: Limit scope of a Falcon A1 IRQ workaround
Date: Mon, 26 Aug 2013 16:31:37 +0400
Message-ID: <521B4AA9.9000906@cogentembedded.com>
References: <1377471363.2586.69.camel@deadeye.wl.decadent.org.uk> <1377471823.2586.76.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:43740 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756671Ab3HZMbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 08:31:42 -0400
Received: by mail-la0-f52.google.com with SMTP id ev20so2316235lab.11
        for <netdev@vger.kernel.org>; Mon, 26 Aug 2013 05:31:41 -0700 (PDT)
In-Reply-To: <1377471823.2586.76.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 26-08-2013 3:03, Ben Hutchings wrote:

> We unconditionally acknowledge legacy interrupts just before disabling
> them.  This workaround is needed on Falcon A1 but probably not on
> later chips where the legacy interrupt mechanism is different.  It was
> also originally done after the IRQ handler was removed, not before.
> Restore the original behaviour for Falcon A1 only by doing this
> acknowledgement in the efx_nic_type::fini operation.

> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>   drivers/net/ethernet/sfc/falcon.c |    4 ++--
>   drivers/net/ethernet/sfc/nic.c    |    7 -------
>   drivers/net/ethernet/sfc/nic.h    |    1 -
>   3 files changed, 2 insertions(+), 10 deletions(-)

> diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
> index f8de382..4492129 100644
> --- a/drivers/net/ethernet/sfc/falcon.c
> +++ b/drivers/net/ethernet/sfc/falcon.c
> @@ -336,7 +336,7 @@ static void falcon_prepare_flush(struct efx_nic *efx)
>    *
>    * NB most hardware supports MSI interrupts
>    */
> -inline void falcon_irq_ack_a1(struct efx_nic *efx)
> +static inline void falcon_irq_ack_a1(struct efx_nic *efx)

    Does inline make sense still when this now is referenced indirectly?

>   {
>   	efx_dword_t reg;
>
> @@ -2343,7 +2343,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
>   	.remove = falcon_remove_nic,
>   	.init = falcon_init_nic,
>   	.dimension_resources = falcon_dimension_resources,
> -	.fini = efx_port_dummy_op_void,
> +	.fini = falcon_irq_ack_a1,
>   	.monitor = falcon_monitor,
>   	.map_reset_reason = falcon_map_reset_reason,
>   	.map_reset_flags = falcon_map_reset_flags,

WBR, Sergei
