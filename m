From: Siva Reddy Kallam <siva.kallam@broadcom.com>
Subject: Re: [PATCH net v2] tg3: Fix for disallow tx coalescing time to be 0
Date: Thu, 1 Sep 2016 15:08:54 +0530
Message-ID: <CAMet4B5KTW1C+K_9KOBizh+pwoPZJygtX0Uk2F-Js85NqxDzfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Satish Baddipadige <satish.baddipadige@broadcom.com>,
        Michael Chan <michael.chan@broadcom.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:33060 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752809AbcIAJiz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 05:38:55 -0400
Received: by mail-qk0-f174.google.com with SMTP id z190so78760682qkc.0
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 02:38:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 1, 2016 at 2:58 PM, Ivan Vecera <ivecera@redhat.com> wrote:
> The recent commit 087d7a8c9174 "tg3: Fix for diasllow rx coalescing
> time to be 0" disallow to set Rx coalescing time to be 0 as this stops
> generating interrupts for the incoming packets. I found the zero
> Tx coalescing time stops generating interrupts for outgoing packets
> as well and fires Tx watchdog later. To avoid this, don't allow to set
> Tx coalescing time to 0 and also remove subsequent checks that become
> senseless.
>
> Cc: satish.baddipadige@broadcom.com
> Cc: siva.kallam@broadcom.com
> Cc: michael.chan@broadcom.com
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
Acked-by: Siva Reddy Kallam <siva.kallam@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 11 +----------
>  1 file changed, 1 insertion(+), 10 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 6592612..a2551bc 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -14012,6 +14012,7 @@ static int tg3_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
>         if ((ec->rx_coalesce_usecs > MAX_RXCOL_TICKS) ||
>             (!ec->rx_coalesce_usecs) ||
>             (ec->tx_coalesce_usecs > MAX_TXCOL_TICKS) ||
> +           (!ec->tx_coalesce_usecs) ||
>             (ec->rx_max_coalesced_frames > MAX_RXMAX_FRAMES) ||
>             (ec->tx_max_coalesced_frames > MAX_TXMAX_FRAMES) ||
>             (ec->rx_coalesce_usecs_irq > max_rxcoal_tick_int) ||
> @@ -14022,16 +14023,6 @@ static int tg3_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
>             (ec->stats_block_coalesce_usecs < min_stat_coal_ticks))
>                 return -EINVAL;
>
> -       /* No rx interrupts will be generated if both are zero */
> -       if ((ec->rx_coalesce_usecs == 0) &&
> -           (ec->rx_max_coalesced_frames == 0))
> -               return -EINVAL;
> -
> -       /* No tx interrupts will be generated if both are zero */
> -       if ((ec->tx_coalesce_usecs == 0) &&
> -           (ec->tx_max_coalesced_frames == 0))
> -               return -EINVAL;
> -
>         /* Only copy relevant parameters, ignore all others. */
>         tp->coal.rx_coalesce_usecs = ec->rx_coalesce_usecs;
>         tp->coal.tx_coalesce_usecs = ec->tx_coalesce_usecs;
> --
> 2.7.3
>
