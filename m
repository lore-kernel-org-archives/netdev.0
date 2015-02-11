From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcmfmac: use msecs_to_jiffies for time conversion
Date: Wed, 11 Feb 2015 19:18:25 +0100
Message-ID: <54DB9CF1.7050606@broadcom.com>
References: <1423218405-17624-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Daniel Kim <dekim@broadcom.com>,
	<linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423218405-17624-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/06/15 11:26, Nicholas Mc Guire wrote:
> This is only an API consolidation and should make things more readable
> it replaces var * HZ / 1000 by msecs_to_jiffies(var).

Acked-by: Arend van Spriel <arend@broadcom.com>
> Signed-off-by: Nicholas Mc Guire<hofrat@osadl.org>
> ---
>
> Patch was only compile tested with x86_64_defconfig + CONFIG_BRCMFMAC=m,
> CONFIG_MMC=m, CONFIG_BRCMFMAC_SDIO=y
>
> Patch is against 3.19.0-rc7 (localversion-next is -next-20150204)
>
>   drivers/net/wireless/brcm80211/brcmfmac/sdio.c |    6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> index 5e9d208..4f9469b 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
> @@ -3972,7 +3972,7 @@ brcmf_sdio_watchdog(unsigned long data)
>   		/* Reschedule the watchdog */
>   		if (bus->wd_timer_valid)
>   			mod_timer(&bus->timer,
> -				  jiffies + BRCMF_WD_POLL_MS * HZ / 1000);
> +				  jiffies + msecs_to_jiffies(BRCMF_WD_POLL_MS));
>   	}
>   }
>
> @@ -4291,13 +4291,13 @@ void brcmf_sdio_wd_timer(struct brcmf_sdio *bus, uint wdtick)
>   			   dynamically changed or in the first instance
>   			 */
>   			bus->timer.expires =
> -				jiffies + BRCMF_WD_POLL_MS * HZ / 1000;
> +				jiffies + msecs_to_jiffies(BRCMF_WD_POLL_MS);
>   			add_timer(&bus->timer);
>
>   		} else {
>   			/* Re arm the timer, at last watchdog period */
>   			mod_timer(&bus->timer,
> -				jiffies + BRCMF_WD_POLL_MS * HZ / 1000);
> +				jiffies + msecs_to_jiffies(BRCMF_WD_POLL_MS));
>   		}
>
>   		bus->wd_timer_valid = true;
