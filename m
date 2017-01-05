From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] net: stmmac: fix maxmtu assignment to be within valid range
Date: Thu, 5 Jan 2017 23:06:33 +0200
Message-ID: <CAHp75Ve6c4W-eqWdqabX5Q5cX4SpqmxByb6=TKnrr1yodkoPkw@mail.gmail.com>
References: <1483613277-6005-1-git-send-email-hock.leong.kweh@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        seraphin.bonnaffe@st.com, Jarod Wilson <jarod@redhat.com>,
        Alexandre TORGUE <alexandre.torgue@gmail.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Johan Hovold <johan@kernel.org>, Pavel Machek <pavel@ucw.cz>,
        lars.persson@axis.com, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483613277-6005-1-git-send-email-hock.leong.kweh@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 5, 2017 at 12:47 PM, Kweh, Hock Leong
<hock.leong.kweh@intel.com> wrote:
> From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
>
> There is no checking valid value of maxmtu when getting it from devicetree.

'Device Tree' or 'device tree' ?

> This resolution added the checking condition to ensure the assignment is
> made within a valid range.

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 39eb7a6..683d59f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -3319,7 +3319,8 @@ int stmmac_dvr_probe(struct device *device,
>                 ndev->max_mtu = JUMBO_LEN;
>         else
>                 ndev->max_mtu = SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN);
> -       if (priv->plat->maxmtu < ndev->max_mtu)
> +       if ((priv->plat->maxmtu < ndev->max_mtu) &&
> +           (priv->plat->maxmtu >= ndev->min_mtu))
>                 ndev->max_mtu = priv->plat->maxmtu;

Perhaps add a warning message on else branch?

-- 
With Best Regards,
Andy Shevchenko
