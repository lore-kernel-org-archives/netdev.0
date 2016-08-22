From: Kedari Appana <kedare06@gmail.com>
Subject: Re: [PATCH -next v2] net: phy: Add missing of_node_put() in xgmiitorgmii_probe()
Date: Mon, 22 Aug 2016 19:40:41 +0530
Message-ID: <CANdmM3POSz9GmoFEr7jRD23m2gR7K2pK3oU6E5wyTKcUpWO8LA@mail.gmail.com>
References: <1471706815-27723-1-git-send-email-weiyj.lk@gmail.com> <1471819575-13389-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: f.fainelli@gmail.com, michal.simek@xilinx.com,
        soren.brinkmann@xilinx.com, Andrew Lunn <andrew@lunn.ch>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:33712 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754922AbcHVOKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 10:10:43 -0400
Received: by mail-oi0-f67.google.com with SMTP id s207so11940597oie.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 07:10:43 -0700 (PDT)
In-Reply-To: <1471819575-13389-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi ,


On Mon, Aug 22, 2016 at 4:16 AM, Wei Yongjun <weiyj.lk@gmail.com> wrote:
> This node pointer is returned by of_parse_phandle() with
> refcount incremented in this function. of_node_put() on it
> before exitting this function.
>
> This is detected by Coccinelle semantic patch.
>
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Reviewed-by: Kedareswara rao Appana <appanad@xilinx.com>

Thanks,
Kedar.

> ---
> v1 -> v2: release it unconditionally as Andrew and David's suggestion
> ---
>  drivers/net/phy/xilinx_gmii2rgmii.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/phy/xilinx_gmii2rgmii.c b/drivers/net/phy/xilinx_gmii2rgmii.c
> index cad6e19..73b50f3 100644
> --- a/drivers/net/phy/xilinx_gmii2rgmii.c
> +++ b/drivers/net/phy/xilinx_gmii2rgmii.c
> @@ -73,6 +73,7 @@ int xgmiitorgmii_probe(struct mdio_device *mdiodev)
>         }
>
>         priv->phy_dev = of_phy_find_device(phy_node);
> +       of_node_put(phy_node);
>         if (!priv->phy_dev) {
>                 dev_info(dev, "Couldn't find phydev\n");
>                 return -EPROBE_DEFER;
>
