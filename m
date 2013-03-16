From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: Re: [net PATCH 1/1] drivers: net: ethernet: ti: davinci_emac: fix
 usage of cpdma_check_free_tx_desc()
Date: Sat, 16 Mar 2013 12:43:14 +0530
Message-ID: <CA+V-a8sM9q6eVqu8nMf1S1jhZEf3zJsPYr_8_waRinfeX17t5w@mail.gmail.com>
References: <1363356616-32480-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-omap@vger.kernel.org,
	dlos <davinci-linux-open-source@linux.davincidsp.com>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:54116 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349Ab3CPHNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 03:13:37 -0400
In-Reply-To: <1363356616-32480-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mugunthan

Thanks for the patch!

On Fri, Mar 15, 2013 at 7:40 PM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
> Fix which was done in the following commit in cpsw driver has
> to be taken forward to davinci emac driver as well.
>
> commit d35162f89b8f00537d7b240b76d2d0e8b8d29aa0
> Author: Daniel Mack <zonque@gmail.com>
> Date:   Tue Mar 12 06:31:19 2013 +0000
>
>     net: ethernet: cpsw: fix usage of cpdma_check_free_tx_desc()
>
>     Commit fae50823d0 ("net: ethernet: davinci_cpdma: Add boundary for rx
>     and tx descriptors") introduced a function to check the current
>     allocation state of tx packets. The return value is taken into account
>     to stop the netqork queue on the adapter in case there are no free
>     slots.
>
>     However, cpdma_check_free_tx_desc() returns 'true' if there is room in
>     the bitmap, not 'false', so the usage of the function is wrong.
>
> Reported-by: Prabhakar Lad <prabhakar.csengg@gmail.com>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

 Tested-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Cheers,
--Prabhakar Lad
http://www.linkedin.com/pub/prabhakar-lad/19/92b/955

> ---
>  drivers/net/ethernet/ti/davinci_emac.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
> index 52c0536..ae1b77a 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -1102,7 +1102,7 @@ static int emac_dev_xmit(struct sk_buff *skb, struct net_device *ndev)
>         /* If there is no more tx desc left free then we need to
>          * tell the kernel to stop sending us tx frames.
>          */
> -       if (unlikely(cpdma_check_free_tx_desc(priv->txchan)))
> +       if (unlikely(!cpdma_check_free_tx_desc(priv->txchan)))
>                 netif_stop_queue(ndev);
>
>         return NETDEV_TX_OK;
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-omap" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
