From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH] davinci: da850/omap-l138: Add Carrier Link OK check in
 Davinci RX Handler
Date: Fri, 25 Feb 2011 14:55:45 +0300
Message-ID: <4D6798C1.7090404@mvista.com>
References: <1298627788-32339-1-git-send-email-vinay.hegde@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-arm-kernel@lists.infradead.org
To: "Hegde, Vinay" <vinay.hegde@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:45697 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999Ab1BYL5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 06:57:06 -0500
Received: by ewy6 with SMTP id 6so558581ewy.19
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 03:57:05 -0800 (PST)
In-Reply-To: <1298627788-32339-1-git-send-email-vinay.hegde@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 25-02-2011 12:56, Hegde, Vinay wrote:

    This is not a patch to arch/arm/mach-davinci/, so the summary prefix 
should not be "davinci: da850/omap-l138:" but rather "davinci_emac:" as you're 
patching this driver.

> This patch adds an additional check in the Davinci EMAC RX Handler,
> which tests the __LINK_STATE_NOCARRIER flag along with the
> __LINK_STATE_START flag as part EMAC shutting down procedure.

> This avoids
> WARNING: at drivers/net/davinci_emac.c:1040 emac_rx_handler+0xf8/0x120()
> during rtcwake used to suspend the target for a specified duration.

> Signed-off-by: Hegde, Vinay <vinay.hegde@ti.com>

> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
> index 2a628d1..7018bfe 100644
> --- a/drivers/net/davinci_emac.c
> +++ b/drivers/net/davinci_emac.c
> @@ -1008,7 +1008,7 @@ static void emac_rx_handler(void *token, int len, int status)
>   	int			ret;
>
>   	/* free and bail if we are shutting down */
> -	if (unlikely(!netif_running(ndev))) {
> +	if (unlikely(!netif_running(ndev) || !netif_carrier_ok(ndev))) {
>   		dev_kfree_skb_any(skb);
>   		return;
>   	}

WBR, Sergei
