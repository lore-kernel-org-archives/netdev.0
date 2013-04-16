From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH for 3.9] net: fec: fix regression in link change accounting
Date: Tue, 16 Apr 2013 10:40:39 -0300
Message-ID: <CAOMZO5DSPqfjRNsoot3Bo8ZJzTJfbkSZbMPkLjK9tqbqCYeQ2A@mail.gmail.com>
References: <1366108962-8607-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f50.google.com ([209.85.212.50]:49891 "EHLO
	mail-vb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932450Ab3DPNkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 09:40:40 -0400
Received: by mail-vb0-f50.google.com with SMTP id w15so367576vbb.37
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 06:40:39 -0700 (PDT)
In-Reply-To: <1366108962-8607-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lucas,

On Tue, Apr 16, 2013 at 7:42 AM, Lucas Stach <l.stach@pengutronix.de> wrote:
> A link-down isn't properly saved in the FEC state, so we wouldn't restart the
> FEC after a repeated link-up.
>
> Regression was introduced with commit
> d97e7497 "net: fec: restart the FEC when PHY speed changes"
>
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> ---
>  drivers/net/ethernet/freescale/fec.c |    1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> index f292c3a..73195f6 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -1002,6 +1002,7 @@ static void fec_enet_adjust_link(struct net_device *ndev)
>         } else {
>                 if (fep->link) {
>                         fec_stop(ndev);
> +                       fep->link = phy_dev->link;
>                         status_change = 1;
>                 }
>         }

I applied this into linux-next (the file is renamed to fec_main.c
there) and this fixes the suspend/resume issue I was seeing.

Tested-by: Fabio Estevam <fabio.estevam@freescale.com>
