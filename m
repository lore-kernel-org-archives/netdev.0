From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: Re: [PATCH 6/8] bcm63xx_enet: just use "enet" as the clock name
Date: Wed, 6 Sep 2017 13:00:26 +0200
Message-ID: <CAOiHx=nvzGybbsTy+y54TetDAQ5zZBLZ3pJh7EVAZM_VbzVS9A@mail.gmail.com>
References: <20170802093429.12572-1-jonas.gorski@gmail.com> <20170802093429.12572-7-jonas.gorski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        bcm-kernel-feedback-list <bcm-kernel-feedback-list@broadcom.com>,
        Kevin Cernekee <cernekee@gmail.com>,
        Jiri Slaby <jslaby@suse.com>,
        "David S. Miller" <davem@davemloft.net>,
        Russell King <linux@armlinux.org.uk>
To: MIPS Mailing List <linux-mips@linux-mips.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-serial@vger.kernel.org" <linux-serial@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:37952 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752900AbdIFLAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 07:00:47 -0400
In-Reply-To: <20170802093429.12572-7-jonas.gorski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On 2 August 2017 at 11:34, Jonas Gorski <jonas.gorski@gmail.com> wrote:
> Now that we have the individual clocks available as "enet" we
> don't need to rely on the device id for them anymore.
>
> Signed-off-by: Jonas Gorski <jonas.gorski@gmail.com>

Could I please get a (N)Ack so Ralf can add this patch to his tree?


Regards
Jonas

> ---
>  drivers/net/ethernet/broadcom/bcm63xx_enet.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> index 61a88b64bd39..d6844923a1c0 100644
> --- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> +++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> @@ -1718,7 +1718,6 @@ static int bcm_enet_probe(struct platform_device *pdev)
>         struct bcm63xx_enet_platform_data *pd;
>         struct resource *res_mem, *res_irq, *res_irq_rx, *res_irq_tx;
>         struct mii_bus *bus;
> -       const char *clk_name;
>         int i, ret;
>
>         /* stop if shared driver failed, assume driver->probe will be
> @@ -1761,14 +1760,12 @@ static int bcm_enet_probe(struct platform_device *pdev)
>         if (priv->mac_id == 0) {
>                 priv->rx_chan = 0;
>                 priv->tx_chan = 1;
> -               clk_name = "enet0";
>         } else {
>                 priv->rx_chan = 2;
>                 priv->tx_chan = 3;
> -               clk_name = "enet1";
>         }
>
> -       priv->mac_clk = clk_get(&pdev->dev, clk_name);
> +       priv->mac_clk = clk_get(&pdev->dev, "enet");
>         if (IS_ERR(priv->mac_clk)) {
>                 ret = PTR_ERR(priv->mac_clk);
>                 goto out;
> --
> 2.13.2
>
