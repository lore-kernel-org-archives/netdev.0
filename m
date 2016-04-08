From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 2/2] net-ath9k_htc: Replace a variable initialisation by
 an assignment in ath9k_htc_set_channel()
Date: Fri, 8 Apr 2016 11:40:45 +1000
Message-ID: <CAGRGNgXR_OoER0rN5Z8n_5VtZimpU7WDNZuc4vkdb2eKDT2frQ@mail.gmail.com>
References: <566ABCD9.1060404@users.sourceforge.net> <5686C390.5060600@users.sourceforge.net>
 <5686C47E.1040906@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ath9k-devel@lists.ath9k.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	LKML <linux-kernel@vger.kernel.org>,
	SF Markus Elfring <elfring@users.sourceforge.net>,
	kernel-janitors <kernel-janitors@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5686C47E.1040906@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kalle,

On Sat, Jan 2, 2016 at 5:25 AM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 1 Jan 2016 19:09:32 +0100
>
> Replace an explicit initialisation for one local variable at the beginning
> by a conditional assignment.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

This looks sane to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks,

Julian Calaby

> ---
>  drivers/net/wireless/ath/ath9k/htc_drv_main.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
> index a680a97..30bd59e 100644
> --- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
> +++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
> @@ -246,7 +246,7 @@ static int ath9k_htc_set_channel(struct ath9k_htc_priv *priv,
>         struct ieee80211_conf *conf = &common->hw->conf;
>         bool fastcc;
>         struct ieee80211_channel *channel = hw->conf.chandef.chan;
> -       struct ath9k_hw_cal_data *caldata = NULL;
> +       struct ath9k_hw_cal_data *caldata;
>         enum htc_phymode mode;
>         __be16 htc_mode;
>         u8 cmd_rsp;
> @@ -274,10 +274,7 @@ static int ath9k_htc_set_channel(struct ath9k_htc_priv *priv,
>                 priv->ah->curchan->channel,
>                 channel->center_freq, conf_is_ht(conf), conf_is_ht40(conf),
>                 fastcc);
> -
> -       if (!fastcc)
> -               caldata = &priv->caldata;
> -
> +       caldata = fastcc ? NULL : &priv->caldata;
>         ret = ath9k_hw_reset(ah, hchan, caldata, fastcc);
>         if (ret) {
>                 ath_err(common,
> --
> 2.6.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
