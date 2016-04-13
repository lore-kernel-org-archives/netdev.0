From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RESEND PATCH net-next] phy: keep the BCMR_LOOPBACK bit while
 setup forced mode
Date: Wed, 13 Apr 2016 11:41:49 -0700
Message-ID: <570E92ED.9020603@gmail.com>
References: <570E3488.9060403@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch
To: Weidong Wang <wangweidong1@huawei.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570E3488.9060403@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/04/16 04:59, Weidong Wang wrote:
> When tested the PHY SGMII Loopback,:
> 1.set the LOOPBACK bit,
> 2.set the autoneg to AUTONEG_DISABLE, it calls the
> genphy_setup_forced which will clear the bit.
> 
> So just keep the LOOPBACK bit while setup forced mode.

Humm, it makes sense why we want this one, but maybe we want other bits
to be preserved too, like MII_ISOLATE for instance?

Or maybe we should have a separate way to put the PHY into loopback mode
which is deterministic and takes care of forcing the link at the same time?

> 
> Signed-off-by: Weidong Wang <wangweidong1@huawei.com>
> ---
>  drivers/net/phy/phy_device.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index e551f3a..8da4b80 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -1124,7 +1124,9 @@ static int genphy_config_advert(struct phy_device *phydev)
>  int genphy_setup_forced(struct phy_device *phydev)
>  {
>  	int ctl = 0;
> +	int val = phy_read(phydev, MII_BMCR);
> 
> +	ctl |= val & BMCR_LOOPBACK;
>  	phydev->pause = 0;
>  	phydev->asym_pause = 0;
> 
> -- 2.7.0
> 


-- 
Florian
