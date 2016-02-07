From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 3/5] net: phy: dp83848: Reorganize code for readability
 and safety
Date: Sun, 7 Feb 2016 21:13:56 +0300
Message-ID: <56B78964.4030606@cogentembedded.com>
References: <1454867241-20928-1-git-send-email-afd@ti.com>
 <1454867241-20928-4-git-send-email-afd@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Andrew F. Davis" <afd@ti.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454867241-20928-4-git-send-email-afd@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/07/2016 08:47 PM, Andrew F. Davis wrote:

> Reorganize code by moving the desired interrupt mask definition
> out of function. Also rearrange the enable/disable interrupt function
> to prevent accidental over-writing of values in registers.
>
> Signed-off-by: Andrew F. Davis <afd@ti.com>
> ---
>   drivers/net/phy/dp83848.c | 33 ++++++++++++++++++++-------------
>   1 file changed, 20 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
> index d4686d5f..20d3b9d 100644
> --- a/drivers/net/phy/dp83848.c
> +++ b/drivers/net/phy/dp83848.c
[...]
> @@ -46,23 +52,24 @@ static int dp83848_ack_interrupt(struct phy_device *phydev)
>
>   static int dp83848_config_intr(struct phy_device *phydev)
>   {
> -	int err;
> +	int control, ret;
> +
> +	control = phy_read(phydev, DP83848_MICR);
> +	if (control < 0)
> +		return control;
>
>   	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
> -		err = phy_write(phydev, DP83848_MICR,
> -				DP83848_MICR_INT_OE |
> -				DP83848_MICR_INTEN);
> -		if (err < 0)
> -			return err;
> -
> -		return phy_write(phydev, DP83848_MISR,
> -				 DP83848_MISR_ANC_INT_EN |
> -				 DP83848_MISR_DUP_INT_EN |
> -				 DP83848_MISR_SPD_INT_EN |
> -				 DP83848_MISR_LINK_INT_EN);
> +		control |= DP83848_MICR_INT_OE;
> +		control |= DP83848_MICR_INTEN;

    I'd have written this on a single line.

[...]

MBR, Sergei
