From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH] mwifiex: propagate error if IRQ request fails in
 mwifiex_sdio_of()
Date: Thu, 18 Aug 2016 21:14:35 +0200
Message-ID: <10fb1110-4c0b-00a2-522c-7011ca397b8c@broadcom.com>
References: <1471529868-13669-1-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471529868-13669-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18-08-16 16:17, Javier Martinez Canillas wrote:
> If request_irq() fails in mwifiex_sdio_probe_of(), only an error message
> is printed but the actual error is not propagated to the caller function.

Hmm. The caller function, ie. mwifiex_sdio_probe(), does not seem to care.

The device may still function without this wake interrupt.

Regards,
Arend

> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
> ---
> 
>  drivers/net/wireless/marvell/mwifiex/sdio.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
> index d3e1561ca075..00727936ad6e 100644
> --- a/drivers/net/wireless/marvell/mwifiex/sdio.c
> +++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
> @@ -125,6 +125,7 @@ static int mwifiex_sdio_probe_of(struct device *dev, struct sdio_mmc_card *card)
>  				dev_err(dev,
>  					"Failed to request irq_wifi %d (%d)\n",
>  					cfg->irq_wifi, ret);
> +				return ret;
>  			}
>  			disable_irq(cfg->irq_wifi);
>  		}
> 
