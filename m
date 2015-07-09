From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH v2] brcmsmac: Use kstrdup to simplify code
Date: Thu, 9 Jul 2015 20:36:40 +0200
Message-ID: <559EBF38.70107@broadcom.com>
References: <1436383927-14010-1-git-send-email-christophe.jaillet@wanadoo.fr> <1436386966-16148-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
	<kvalo@codeaurora.org>, <brudley@broadcom.com>,
	<frankyl@broadcom.com>, <meuleman@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436386966-16148-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/08/2015 10:22 PM, Christophe JAILLET wrote:
> Replace a kmalloc+strcpy by an equivalent kstrdup in order to improve
> readability.

Not sure if readability is really the issue here. At most it is a small 
reduction of driver code by using kstrdup(). Anyway, the patch looks fine so

Acked-by: Arend van Spriel <arend@broadcom.com>
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
> v2: fix the subject
>
>   drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c | 4 +---
>   1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
> index 4813506..8a6c077 100644
> --- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
> +++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
> @@ -1476,9 +1476,7 @@ struct brcms_timer *brcms_init_timer(struct brcms_info *wl,
>   	wl->timers = t;
>
>   #ifdef DEBUG
> -	t->name = kmalloc(strlen(name) + 1, GFP_ATOMIC);
> -	if (t->name)
> -		strcpy(t->name, name);
> +	t->name = kstrdup(name, GFP_ATOMIC);
>   #endif
>
>   	return t;
>
