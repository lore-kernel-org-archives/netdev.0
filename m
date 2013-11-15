From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] net: phy: at803x: soft-reset PHY when link goes down
Date: Fri, 15 Nov 2013 03:03:36 +0300
Message-ID: <528564D8.9050504@cogentembedded.com>
References: <1384376870-7810-1-git-send-email-zonque@gmail.com> <1384376870-7810-2-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, marek.belisko@gmail.com, ujhelyi.m@gmail.com
To: Daniel Mack <zonque@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:44771 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010Ab3KNXD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 18:03:27 -0500
Received: by mail-lb0-f178.google.com with SMTP id y6so2087246lbh.23
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 15:03:26 -0800 (PST)
In-Reply-To: <1384376870-7810-2-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/14/2013 12:07 AM, Daniel Mack wrote:

> When the link goes down and up again quickly and multiple times in a
> row, the AT803x PHY gets stuck and won't recover unless it is soft-reset
> via the BMCR register.

> Unfortunately, there is no way to detect this state, as all registers
> contain perfectly sane values in such cases. Hence, the only option is
> to always soft-reset the PHY when the link goes down.

> Reset logic is based on a patch from Marek Belisko.

> Signed-off-by: Daniel Mack <zonque@gmail.com>
> Reported-and-tested-by: Marek Belisko <marek.belisko@gmail.com>
> ---
>   drivers/net/phy/at803x.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 52 insertions(+)

> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index bc71947..303c5ae 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -32,10 +32,56 @@
>   #define AT803X_DEBUG_SYSTEM_MODE_CTRL		0x05
>   #define AT803X_DEBUG_RGMII_TX_CLK_DLY		BIT(8)
>
> +#define AT803X_BMCR_SOFTRESET			BIT(15)
> +

    This is the standard bit (BMCR_RESET) #define'd in the same file as MII_BMCR.

WBR, Sergei
