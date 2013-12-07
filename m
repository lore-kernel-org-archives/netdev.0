From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] net: allwinner: emac: Add missing free_irq
Date: Sat, 07 Dec 2013 20:57:05 +0400
Message-ID: <52A35361.8090608@cogentembedded.com>
References: <1386415902-32697-1-git-send-email-maxime.ripard@free-electrons.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-sunxi+bncBC6MFNV32EFRBX5GRWKQKGQEGYGVIPA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1386415902-32697-1-git-send-email-maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hello.

On 07-12-2013 15:31, Maxime Ripard wrote:

> The sun4i-emac driver uses devm_request_irq at .ndo_open time, but relies on
> the managed device mechanism to actually free it. This causes an issue whenever
> someone wants to restart the interface, the interrupt still being held, and not
> yet released.

> Fall back to using the regular request_irq at .ndo_open time, and introduce a
> free_irq during .ndo_stop.

> Signed-off-by: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> ---
> Hi David,

> It would be great if this patch would be applied to 3.13.

> Thanks,
> Maxime


>   drivers/net/ethernet/allwinner/sun4i-emac.c | 6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
> index 50b853a..38aba50 100644
> --- a/drivers/net/ethernet/allwinner/sun4i-emac.c
> +++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
> @@ -717,8 +717,8 @@ static int emac_open(struct net_device *dev)
>   	if (netif_msg_ifup(db))
>   		dev_dbg(db->dev, "enabling %s\n", dev->name);
>
> -	if (devm_request_irq(db->dev, dev->irq, &emac_interrupt,
> -			     0, dev->name, dev))
> +	if (request_irq(dev->irq, &emac_interrupt,
> +			0, dev->name, dev))

    Doesn't it fit into single line?

WBR, Sergei
