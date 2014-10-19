From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] Net: DSA: Fix checking for get_phy_flags function
Date: Sat, 18 Oct 2014 20:08:50 -0700
Message-ID: <CAGVrzcY5CEA-o46ZoytY75H2pHHEPtCm22FtciUkFTPaRDcRHg@mail.gmail.com>
References: <1413677606-31031-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:57582 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbaJSDJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 23:09:31 -0400
Received: by mail-ig0-f179.google.com with SMTP id h18so2868978igc.12
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 20:09:30 -0700 (PDT)
In-Reply-To: <1413677606-31031-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-10-18 17:13 GMT-07:00 Andrew Lunn <andrew@lunn.ch>:
> The check for the presence or not of the optional switch function
> get_phy_flags() called the function, rather than checking to see if it
> is a NULL pointer. This causes a derefernce of a NULL pointer on all
> switch chips except the sf2, the only switch to implement this call.

Sorry about this one, good catch.

>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Fixes: 6819563e646a "net: dsa=: allow switch drivers to ...

Could you resubmit without stripping the "Fixes" subject?

> Cc: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  net/dsa/slave.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 9d3b12b4e03c..fbcba4bc4e08 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -596,7 +596,7 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
>         netif_carrier_off(slave_dev);
>
>         if (p->phy != NULL) {
> -               if (ds->drv->get_phy_flags(ds, port))
> +               if (ds->drv->get_phy_flags)
>                         p->phy->dev_flags |= ds->drv->get_phy_flags(ds, port);
>
>                 phy_attach(slave_dev, dev_name(&p->phy->dev),
> --
> 2.1.1
>



-- 
Florian
