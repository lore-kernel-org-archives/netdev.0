From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net phy: Check for aneg completion before setting state
 to PHY_RUNNING
Date: Thu, 24 Apr 2014 11:53:51 -0700
Message-ID: <CAGVrzcbrm3KO_=NSJz=KOAcPWvVUMm5kPM7nryJBag6BotKgoQ@mail.gmail.com>
References: <53587C7F.2000808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Balakumaran Kannan <kumaran.4353@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:42163 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229AbaDXSyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 14:54:33 -0400
Received: by mail-qg0-f45.google.com with SMTP id a108so2894118qge.4
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 11:54:32 -0700 (PDT)
In-Reply-To: <53587C7F.2000808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-23 19:52 GMT-07:00 Balakumaran Kannan <kumaran.4353@gmail.com>:
> phy_state_machine should check whether auto-negotiatin is completed
> before changing phydev->state from PHY_NOLINK to PHY_RUNNING. If
> auto-negotiation is not completed phydev->state should be set to
> PHY_AN.

I need some time to review this. Just out of curiosity, is this fixing
a bug you have encountered or was this found by state machine
inspection?

>
> Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
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
