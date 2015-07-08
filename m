From: Emmanuel Grumbach <egrumbach@gmail.com>
Subject: Re: [PATCH] mac80211: Use kstrdup to simplify code
Date: Wed, 8 Jul 2015 22:53:51 +0300
Message-ID: <CANUX_P2djxM92BZX=0O7Zmb+0Y7Gs9xpbfUgPnCB0gnDwfSJuQ@mail.gmail.com>
References: <1436383927-14010-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>, brudley@broadcom.com,
	Arend van Spriel <arend@broadcom.com>, frankyl@broadcom.com,
	meuleman@broadcom.com,
	linux-wireless <linux-wireless@vger.kernel.org>,
	brcm80211-dev-list@broadcom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:34813 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755061AbbGHTxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 15:53:53 -0400
In-Reply-To: <1436383927-14010-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The subject is wrong. You are not patch mac80211, but bcrmsmac.

On Wed, Jul 8, 2015 at 10:32 PM, Christophe JAILLET
<christophe.jaillet@wanadoo.fr> wrote:
> Replace a kmalloc+strcpy by an equivalent kstrdup in order to improve
> readability.
>
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
>  drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
> index 4813506..8a6c077 100644
> --- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
> +++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
> @@ -1476,9 +1476,7 @@ struct brcms_timer *brcms_init_timer(struct brcms_info *wl,
>         wl->timers = t;
>
>  #ifdef DEBUG
> -       t->name = kmalloc(strlen(name) + 1, GFP_ATOMIC);
> -       if (t->name)
> -               strcpy(t->name, name);
> +       t->name = kstrdup(name, GFP_ATOMIC);
>  #endif
>
>         return t;
> --
> 2.1.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
