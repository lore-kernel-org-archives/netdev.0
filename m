From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH] net: phy: at803x: support interrupt on 8030 and 8035
Date: Thu, 12 Nov 2015 20:06:23 +0100
Message-ID: <5644E32F.6010104@free.fr>
References: <1447350020-27969-1-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mans Rullgard <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447350020-27969-1-git-send-email-mans@mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/11/2015 18:40, Mans Rullgard wrote:
> Commit 77a993942 "phy/at8031: enable at8031 to work on interrupt mode"
> added interrupt support for the 8031 PHY but left out the other two
> chips supported by this driver.
> 
> This patch sets the .ack_interrupt and .config_intr functions for the
> 8030 and 8035 drivers as well.
> 
> Signed-off-by: Mans Rullgard <mans@mansr.com>
> ---
> I have only tested this with an 8035.  I can't find a datasheet for
> the 8030, but since 8031, 8032, and 8035 all have the same register
> layout, there's a good chance 8030 does as well.
> ---
>  drivers/net/phy/at803x.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index fabf11d..2d020a3 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -308,6 +308,8 @@ static struct phy_driver at803x_driver[] = {
>  	.flags			= PHY_HAS_INTERRUPT,
>  	.config_aneg		= genphy_config_aneg,
>  	.read_status		= genphy_read_status,
> +	.ack_interrupt		= at803x_ack_interrupt,
> +	.config_intr		= at803x_config_intr,
>  	.driver			= {
>  		.owner = THIS_MODULE,
>  	},
> @@ -327,6 +329,8 @@ static struct phy_driver at803x_driver[] = {
>  	.flags			= PHY_HAS_INTERRUPT,
>  	.config_aneg		= genphy_config_aneg,
>  	.read_status		= genphy_read_status,
> +	.ack_interrupt		= at803x_ack_interrupt,
> +	.config_intr		= at803x_config_intr,
>  	.driver			= {
>  		.owner = THIS_MODULE,
>  	},

Shouldn't we take the opportunity to clean up the duplicated register
definitions? (I'll send an informal patch to spur discussion.)

Regards.
