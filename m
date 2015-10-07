From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcm80211:Fix error handling in the function brcmf_sdio_htclk
Date: Wed, 7 Oct 2015 11:49:48 +0200
Message-ID: <5614EABC.9040404@broadcom.com>
References: <1444099010-27210-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <frankyl@broadcom.com>, <meuleman@broadcom.com>,
	<kvalo@codeaurora.org>, <pieterpg@broadcom.com>,
	<linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>, <brudley@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444099010-27210-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Nick,

On 10/06/2015 04:36 AM, Nicholas Krause wrote:
> This fixes error handling in the function brcmf_sdio_htclk to
> properly check if the call to the function brcmf_sdio_regrb
> fails in the else if condition where the clkstate is in the
> CLK_PENDING state in order to avoid incorrect execution of
> the function brcmf_sdio_htclk when the call to brcmf_sdio_htclk
> fails by returning a error code here.

This commit message seems a bit overstating the change or I am missing 
what you mean by incorrect execution here. These functions are pretty 
low-level and failures are likely SDIO bus errors that are likely 
persistent. For that reason not every individual call is checked for 
errors as net result is that device will become inoperable.

Regards,
Arend

> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>   drivers/net/wireless/brcm80211/brcmfmac/sdio.c | 5 +++++
>   1 file changed, 5 insertions(+)
>
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> index f990e3d..030b50a 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> @@ -886,6 +886,11 @@ static int brcmf_sdio_htclk(struct brcmf_sdio *bus, bool on, bool pendok)
>   			/* Cancel CA-only interrupt filter */
>   			devctl = brcmf_sdiod_regrb(bus->sdiodev,
>   						   SBSDIO_DEVICE_CTL, &err);
> +			if (err) {
> +				brcmf_err("Devctl error canceling CA: %d\n",
> +					  err);
> +				return -EBADE;
> +			}
>   			devctl &= ~SBSDIO_DEVCTL_CA_INT_ONLY;
>   			brcmf_sdiod_regwb(bus->sdiodev, SBSDIO_DEVICE_CTL,
>   					  devctl, &err);
>
