From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phy: IRQ cannot be shared
Date: Fri, 20 Dec 2013 10:24:05 -0800
Message-ID: <CAGVrzcaUamisoHrW-j5RCt4ph=s0X32uUi7yn7_Wi7=5fxi7tw@mail.gmail.com>
References: <201312202209.04333.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:54643 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101Ab3LTSYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 13:24:45 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so2871733pdi.10
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 10:24:45 -0800 (PST)
In-Reply-To: <201312202209.04333.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/12/20 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> With the way PHY IRQ handler is implemented (all real handling being pushed to
> the workqueue and returning IRQ_HANDLED all the time PHY is active), we cannot
> really claim that PHY IRQ can be shared when calling request_irq().

Looks good, in the future we might want to be able to let the Ethernet
MAC driver specify the flags to pass down to request_irq() but this is
good enough for me for the time being.

>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

>
> ---
> The patch is against DaveM's 'net.git' repo.
> I recommend pushing it to the stable kernels as well.
>
>  drivers/net/phy/phy.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> Index: net/drivers/net/phy/phy.c
> ===================================================================
> --- net.orig/drivers/net/phy/phy.c
> +++ net/drivers/net/phy/phy.c
> @@ -565,10 +565,8 @@ int phy_start_interrupts(struct phy_devi
>         int err = 0;
>
>         atomic_set(&phydev->irq_disable, 0);
> -       if (request_irq(phydev->irq, phy_interrupt,
> -                               IRQF_SHARED,
> -                               "phy_interrupt",
> -                               phydev) < 0) {
> +       if (request_irq(phydev->irq, phy_interrupt, 0, "phy_interrupt",
> +                       phydev) < 0) {
>                 pr_warn("%s: Can't get IRQ %d (PHY)\n",
>                         phydev->bus->name, phydev->irq);
>                 phydev->irq = PHY_POLL;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
