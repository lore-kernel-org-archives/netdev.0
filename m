From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net phy: Check for aneg completion before setting state
 to PHY_RUNNING
Date: Wed, 30 Apr 2014 19:11:33 -0700
Message-ID: <CAGVrzcZ0jMD_5t7xygEKgReZQf_3B28rq2wqSJgkjM5d3mX1Sw@mail.gmail.com>
References: <53587C7F.2000808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Balakumaran Kannan <kumaran.4353@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:57121 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbaEACMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 22:12:14 -0400
Received: by mail-qa0-f54.google.com with SMTP id s7so2522021qap.13
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 19:12:13 -0700 (PDT)
In-Reply-To: <53587C7F.2000808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-23 19:52 GMT-07:00 Balakumaran Kannan <kumaran.4353@gmail.com>:
> phy_state_machine should check whether auto-negotiatin is completed
> before changing phydev->state from PHY_NOLINK to PHY_RUNNING. If
> auto-negotiation is not completed phydev->state should be set to
> PHY_AN.
>
> Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/phy.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
>
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 1b6d09a..a972056 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -765,6 +765,17 @@ void phy_state_machine(struct work_struct *work)
>                         break;
>
>                 if (phydev->link) {
> +                       if (AUTONEG_ENABLE == phydev->autoneg) {
> +                               err = phy_aneg_done(phydev);
> +                               if (err < 0)
> +                                       break;
> +
> +                               if (!err) {
> +                                       phydev->state = PHY_AN;
> +                                       phydev->link_timeout = PHY_AN_TIMEOUT;
> +                                       break;
> +                               }
> +                       }
>                         phydev->state = PHY_RUNNING;
>                         netif_carrier_on(phydev->attached_dev);
>                         phydev->adjust_link(phydev->attached_dev);
> --
> 1.8.2.1



-- 
Florian
