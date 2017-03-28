From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: Mock-up driver
Date: Tue, 28 Mar 2017 15:16:20 -0700
Message-ID: <5ce01215-9a87-1ce1-a8dd-9d4b39f7866d@gmail.com>
References: <20170328215624.24888-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33731 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752679AbdC1WQ1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 18:16:27 -0400
Received: by mail-wr0-f195.google.com with SMTP id u18so5318640wrc.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 15:16:26 -0700 (PDT)
In-Reply-To: <20170328215624.24888-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2017 02:56 PM, Florian Fainelli wrote:
> This patch adds support for a DSA mock-up driver which essentially does
> the following:
> 
> - registers/unregisters 4 fixed PHYs to the slave network devices
> - uses eth0 (configurable) as the master netdev
> - registers the switch as a fixed MDIO device against the fixed MDIO bus
>   at address 31
> - includes dynamic debug prints for dsa_switch_ops functions that can be
>   enabled to get call traces
> 
> This is a good way to test modular builds as well as exercise the DSA
> APIs without requiring access to real hardware. This does not test the
> data-path, although this could be added later on.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---

> diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
> index 1d41ec44e39d..e352bc315e00 100644
> --- a/include/linux/phy_fixed.h
> +++ b/include/linux/phy_fixed.h
> @@ -26,6 +26,7 @@ extern int fixed_phy_set_link_update(struct phy_device *phydev,
>  extern int fixed_phy_update_state(struct phy_device *phydev,
>  			   const struct fixed_phy_status *status,
>  			   const struct fixed_phy_status *changed);
> +extern struct device *platform_fmb_bus_get(void);

This is from a previous iteration of the driver and is no longer
required, I will respin, provided that we see value in having this
driver live in the kernel.
-- 
Florian
