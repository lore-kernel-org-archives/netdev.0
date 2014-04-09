From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: Add default vlan for dual
 emac case also
Date: Wed, 9 Apr 2014 15:42:33 +0200
Message-ID: <CAGm1_ku3Fc=Lh8K17M=PCZT491KP-UvFR0BE6mvb5zrr8ybc9Q@mail.gmail.com>
References: <1397023480-4181-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:43973 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932826AbaDINmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 09:42:55 -0400
Received: by mail-pd0-f178.google.com with SMTP id x10so2457530pdj.23
        for <netdev@vger.kernel.org>; Wed, 09 Apr 2014 06:42:54 -0700 (PDT)
In-Reply-To: <1397023480-4181-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 9, 2014 at 8:04 AM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
> Dual EMAC works with VLAN segregation of the ports, so default vlan needs
> to be added in dual EMAC case else default vlan will be tagged for all
> egress packets and vlan unaware switches/servers will drop packets
> from the EVM.
>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
>  drivers/net/ethernet/ti/cpsw.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 5d5fec6..6133e4a 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1201,8 +1201,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
>         for_each_slave(priv, cpsw_slave_open, priv);
>
>         /* Add default VLAN */
> -       if (!priv->data.dual_emac)
> -               cpsw_add_default_vlan(priv);
> +       cpsw_add_default_vlan(priv);
>
>         if (!cpsw_common_res_usage_state(priv)) {
>                 /* setup tx dma to fixed prio and zero offset */
> --
> 1.9.0

Tested-by: Yegor Yefremov <yegorslists@googlemail.com>
