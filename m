From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH v2] net: stmmac: fix maxmtu assignment to be within
 valid range
Date: Fri, 6 Jan 2017 15:55:04 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C5A918B87@PGSMSX102.gar.corp.intel.com>
References: <1483697306-10063-1-git-send-email-hock.leong.kweh@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Alexandre TORGUE <alexandre.torgue@gmail.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Johan Hovold <johan@kernel.org>, "pavel@ucw.cz" <pavel@ucw.cz>,
        "lars.persson@axis.com" <lars.persson@axis.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        "seraphin.bonnaffe@st.com" <seraphin.bonnaffe@st.com>,
        Jarod Wilson <jarod@redhat.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483697306-10063-1-git-send-email-hock.leong.kweh@intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Kweh, Hock Leong
> Sent: Friday, January 06, 2017 6:08 PM
> To: David S. Miller <davem@davemloft.net>; Joao Pinto
> <Joao.Pinto@synopsys.com>; Giuseppe CAVALLARO <peppe.cavallaro@st.com>;
> seraphin.bonnaffe@st.com; Jarod Wilson <jarod@redhat.com>; Andy
> Shevchenko <andy.shevchenko@gmail.com>
> Cc: Alexandre TORGUE <alexandre.torgue@gmail.com>; Joachim Eastwood
> <manabian@gmail.com>; Niklas Cassel <niklas.cassel@axis.com>; Johan Hovold
> <johan@kernel.org>; pavel@ucw.cz; Kweh, Hock Leong
> <hock.leong.kweh@intel.com>; lars.persson@axis.com; netdev
> <netdev@vger.kernel.org>; LKML <linux-kernel@vger.kernel.org>
> Subject: [PATCH v2] net: stmmac: fix maxmtu assignment to be within valid
> range
> 
> From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
> 
> There is no checking valid value of maxmtu when getting it from device tree.
> This resolution added the checking condition to ensure the assignment is made
> within a valid range.
> 
> Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>

I am going to submit V3.

> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 92ac006..4df555e 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -3345,8 +3345,14 @@ int stmmac_dvr_probe(struct device *device,
>  		ndev->max_mtu = JUMBO_LEN;
>  	else
>  		ndev->max_mtu = SKB_MAX_HEAD(NET_SKB_PAD +
> NET_IP_ALIGN);
> -	if (priv->plat->maxmtu < ndev->max_mtu)
> +
> +	if ((priv->plat->maxmtu < ndev->max_mtu) &&
> +	    (priv->plat->maxmtu >= ndev->min_mtu))
>  		ndev->max_mtu = priv->plat->maxmtu;
> +	else if (priv->plat->maxmtu != 0)
> +		netdev_warn(priv->dev,
> +			    "%s: warning: maxmtu having invalid value (%d)\n",
> +			    __func__, priv->plat->maxmtu);
> 
>  	if (flow_ctrl)
>  		priv->flow_ctrl = FLOW_AUTO;	/* RX/TX pause on */
> --
> 1.7.9.5
