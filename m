From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcmfmac: only lock and unlock fws if fws is not null
Date: Wed, 2 Dec 2015 14:03:40 +0100
Message-ID: <565EEC2C.7030501@broadcom.com>
References: <1449056710-9776-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>,
	<kernel-tram@lists.ubuntu.com>,
	Brett Rudley <brudley@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Arnd Bergmann <arnd@arndb.de>,
	<linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449056710-9776-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/02/2015 12:45 PM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> There is a null ptr check for fws to set bcmc_credit_check, however,
> there a lock and unlock on fws should only performed if fwts is
> also not null to also avoid a potential null pointer deference.

Acked-by: Arend van Spriel <arend@broadcom.com>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>   drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c | 7 ++++---
>   1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c b/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
> index 086cac3..092f33f 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
> @@ -1609,10 +1609,11 @@ static int brcmf_fws_notify_bcmc_credit_support(struct brcmf_if *ifp,
>   {
>   	struct brcmf_fws_info *fws = ifp->drvr->fws;
>
> -	brcmf_fws_lock(fws);
> -	if (fws)
> +	if (fws) {
> +		brcmf_fws_lock(fws);
>   		fws->bcmc_credit_check = true;
> -	brcmf_fws_unlock(fws);
> +		brcmf_fws_unlock(fws);
> +	}
>   	return 0;
>   }
>
>
