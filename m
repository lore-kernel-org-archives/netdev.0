From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 1/6] pch_gbe: print invalid MAC address during probe
Date: Thu, 5 Jun 2014 11:00:13 -0700
Message-ID: <CAGVrzcbyD7xKHCeE0S28+bjdja82EGWr9TXute7uQjsefsu8NQ@mail.gmail.com>
References: <1401958387-8154-1-git-send-email-alexander.stein@systec-electronic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Krueger <daniel.krueger@systec-electronic.com>,
	netdev <netdev@vger.kernel.org>
To: Alexander Stein <alexander.stein@systec-electronic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:49789 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbaFESAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 14:00:54 -0400
Received: by mail-qg0-f50.google.com with SMTP id z60so2190527qgd.9
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 11:00:53 -0700 (PDT)
In-Reply-To: <1401958387-8154-1-git-send-email-alexander.stein@systec-electronic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-06-05 1:53 GMT-07:00 Alexander Stein
<alexander.stein@systec-electronic.com>:
> From: Daniel Krueger <daniel.krueger@systec-electronic.com>
>
> It is also neat to show the actual offending MAC address instead of just
> rejecting it

Most drivers do use a random Ethernet MAC address instead of bailing
out, which might be a more sensible option.

>
> Signed-off-by: Daniel Krueger <daniel.krueger@systec-electronic.com>
> Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
> ---
>
> Changes in v2:
> * Use just a single line
>
>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> index 73e6683..cf3101c 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> @@ -2672,8 +2672,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
>                  * prevent the interface from being brought up until a valid MAC
>                  * is set.
>                  */
> -               dev_err(&pdev->dev, "Invalid MAC address, "
> -                                   "interface disabled.\n");
> +               dev_err(&pdev->dev, "Invalid MAC address %pM - interface disabled.\n", adapter->hw.mac.addr);
>         }
>         setup_timer(&adapter->watchdog_timer, pch_gbe_watchdog,
>                     (unsigned long)adapter);
> --
> 1.8.5.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
