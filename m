From: Rajat Jain <rajatja@google.com>
Subject: Re:
Date: Tue, 27 Sep 2016 09:57:29 -0700
Message-ID: <CACK8Z6FA8HfOUvHPPD1snyBxxobT87PvWvkNRD_ymwkugBzrwQ@mail.gmail.com>
References: <1474995052-122337-1-git-send-email-rajatja@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei-Ning Huang <wnhuang@google.com>,
        Brian Norris <briannorris@google.com>,
        Eric Caruso <ejcaruso@chromium.org>,
        Rajat Jain <rajatxjain@gmail.com>,
        Rajat Jain <rajatja@google.com>
To: Amitkumar Karwar <akarwar@marvell.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f177.google.com ([209.85.213.177]:34794 "EHLO
        mail-yb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933838AbcI0Q6L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 12:58:11 -0400
Received: by mail-yb0-f177.google.com with SMTP id e2so5659991ybi.1
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 09:58:10 -0700 (PDT)
In-Reply-To: <1474995052-122337-1-git-send-email-rajatja@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please ignore, not sure why this landed without a subject.

On Tue, Sep 27, 2016 at 9:50 AM, Rajat Jain <rajatja@google.com> wrote:
> From: Wei-Ning Huang <wnhuang@google.com>
>
> Date: Thu, 17 Mar 2016 11:43:16 +0800
> Subject: [PATCH] mwifiex: report wakeup for wowlan
>
> Enable notifying wakeup source to the PM core. This allow darkresume to
> correctly track wakeup source and mark mwifiex_plt as 'automatic' wakeup
> source.
>
> Signed-off-by: Wei-Ning Huang <wnhuang@google.com>
> Signed-off-by: Rajat Jain <rajatja@google.com>
> Tested-by: Wei-Ning Huang <wnhuang@chromium.org>
> Reviewed-by: Eric Caruso <ejcaruso@chromium.org>
> ---
>  drivers/net/wireless/marvell/mwifiex/sdio.c | 8 ++++++++
>  drivers/net/wireless/marvell/mwifiex/sdio.h | 1 +
>  2 files changed, 9 insertions(+)
>
> diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
> index d3e1561..a5f63e4 100644
> --- a/drivers/net/wireless/marvell/mwifiex/sdio.c
> +++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
> @@ -89,6 +89,9 @@ static irqreturn_t mwifiex_wake_irq_wifi(int irq, void *priv)
>                 disable_irq_nosync(irq);
>         }
>
> +       /* Notify PM core we are wakeup source */
> +       pm_wakeup_event(cfg->dev, 0);
> +
>         return IRQ_HANDLED;
>  }
>
> @@ -112,6 +115,7 @@ static int mwifiex_sdio_probe_of(struct device *dev, struct sdio_mmc_card *card)
>                                           GFP_KERNEL);
>         cfg = card->plt_wake_cfg;
>         if (cfg && card->plt_of_node) {
> +               cfg->dev = dev;
>                 cfg->irq_wifi = irq_of_parse_and_map(card->plt_of_node, 0);
>                 if (!cfg->irq_wifi) {
>                         dev_dbg(dev,
> @@ -130,6 +134,10 @@ static int mwifiex_sdio_probe_of(struct device *dev, struct sdio_mmc_card *card)
>                 }
>         }
>
> +       ret = device_init_wakeup(dev, true);
> +       if (ret)
> +               dev_err(dev, "fail to init wakeup for mwifiex");
> +
>         return 0;
>  }
>
> diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.h b/drivers/net/wireless/marvell/mwifiex/sdio.h
> index db837f1..07cdd23 100644
> --- a/drivers/net/wireless/marvell/mwifiex/sdio.h
> +++ b/drivers/net/wireless/marvell/mwifiex/sdio.h
> @@ -155,6 +155,7 @@
>  } while (0)
>
>  struct mwifiex_plt_wake_cfg {
> +       struct device *dev;
>         int irq_wifi;
>         bool wake_by_wifi;
>  };
> --
> 2.8.0.rc3.226.g39d4020
>
