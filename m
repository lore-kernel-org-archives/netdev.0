From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH -next] net: ethernet: nb8800: fix error return code in nb8800_open()
Date: Mon, 17 Oct 2016 16:35:10 +0100
Message-ID: <yw1xmvi3kmz5.fsf@unicorn.mansr.com>
References: <1476718318-28428-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: jarod@redhat.com, sf84@laposte.net, peter.chen@nxp.com,
        tremyfr@gmail.com, arnd@arndb.de, f.fainelli@gmail.com,
        Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:57526 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754792AbcJQPfO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 11:35:14 -0400
In-Reply-To: <1476718318-28428-1-git-send-email-weiyj.lk@gmail.com> (Wei
        Yongjun's message of "Mon, 17 Oct 2016 15:31:58 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Yongjun <weiyj.lk@gmail.com> writes:

> From: Wei Yongjun <weiyongjun1@huawei.com>
>
> Fix to return error code -ENODEV from the of_phy_connect() error
> handling case instead of 0, as done elsewhere in this function.
>
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Acked-by: Mans Rullgard <mans@mansr.com>

> ---
>  drivers/net/ethernet/aurora/nb8800.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
> index 453dc09..99c4055 100644
> --- a/drivers/net/ethernet/aurora/nb8800.c
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -975,8 +975,10 @@ static int nb8800_open(struct net_device *dev)
>  	phydev = of_phy_connect(dev, priv->phy_node,
>  				nb8800_link_reconfigure, 0,
>  				priv->phy_mode);
> -	if (!phydev)
> +	if (!phydev) {
> +		err = -ENODEV;
>  		goto err_free_irq;
> +	}
>
>  	nb8800_pause_adv(dev);
>

-- 
Måns Rullgård
