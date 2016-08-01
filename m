From: Jon Mason <jdmason@kudzu.us>
Subject: Re: [PATCH 1/1] net: s2io: simplify logical constraint
Date: Mon, 1 Aug 2016 12:15:55 -0400
Message-ID: <CAPoiz9w7gSzOt+y963OyViiL1LDKCzUmApwvVp25k8Ef5ixseg@mail.gmail.com>
References: <1469958837-1044-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:35562 "EHLO
	mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977AbcHAQdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 12:33:36 -0400
Received: by mail-vk0-f66.google.com with SMTP id x130so5909129vkc.2
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2016 09:32:07 -0700 (PDT)
In-Reply-To: <1469958837-1044-1-git-send-email-xypron.glpk@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 31, 2016 at 5:53 AM, Heinrich Schuchardt <xypron.glpk@gmx.de> wrote:
> (!A || (A && B)) is equivalent to (!A || B)

Seems logical to me.

Acked-by: Jon Mason <jdmason@kudzu.us>

> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> ---
>  drivers/net/ethernet/neterion/s2io.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
> index 2874dff..eaa37c0 100644
> --- a/drivers/net/ethernet/neterion/s2io.c
> +++ b/drivers/net/ethernet/neterion/s2io.c
> @@ -7412,7 +7412,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
>
>         if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) &&
>             ((!ring_data->lro) ||
> -            (ring_data->lro && (!(rxdp->Control_1 & RXD_FRAME_IP_FRAG)))) &&
> +            (!(rxdp->Control_1 & RXD_FRAME_IP_FRAG))) &&
>             (dev->features & NETIF_F_RXCSUM)) {
>                 l3_csum = RXD_GET_L3_CKSUM(rxdp->Control_1);
>                 l4_csum = RXD_GET_L4_CKSUM(rxdp->Control_1);
> --
> 2.8.1
>
