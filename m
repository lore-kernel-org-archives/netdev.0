From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RESEND PATCH net-next] phy: keep the BCMR_LOOPBACK bit while
 setup forced mode
Date: Wed, 13 Apr 2016 17:19:56 +0300
Message-ID: <570E558C.9010304@cogentembedded.com>
References: <570E3488.9060403@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Weidong Wang <wangweidong1@huawei.com>,
	David Miller <davem@davemloft.net>, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570E3488.9060403@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 4/13/2016 2:59 PM, Weidong Wang wrote:

> When tested the PHY SGMII Loopback,:
> 1.set the LOOPBACK bit,
> 2.set the autoneg to AUTONEG_DISABLE, it calls the
> genphy_setup_forced which will clear the bit.
>
> So just keep the LOOPBACK bit while setup forced mode.
>
> Signed-off-by: Weidong Wang <wangweidong1@huawei.com>
> ---
>   drivers/net/phy/phy_device.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index e551f3a..8da4b80 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -1124,7 +1124,9 @@ static int genphy_config_advert(struct phy_device *phydev)
>   int genphy_setup_forced(struct phy_device *phydev)
>   {
>   	int ctl = 0;
> +	int val = phy_read(phydev, MII_BMCR);

    Please place this declaration first, DaveM prefers declarations to be 
sorted from longest to shortest.

>
> +	ctl |= val & BMCR_LOOPBACK;

    Just =, removing the 'ctl' initializer, please.

[...]

MBR, Sergei
