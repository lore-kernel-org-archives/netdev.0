From: Quan Nguyen <qnguyen@apm.com>
Subject: Re: [PATCH net-next] drivers: net: xgene: Check all RGMII phy mode variants
Date: Thu, 18 May 2017 11:39:48 +0700
Message-ID: <CAFopSPTP07TFcgc8pACQDF4ZXHOftUMBqBCgF4hVpAmUt0cCWw@mail.gmail.com>
References: <1495051550-28961-1-git-send-email-isubramanian@apm.com> <20170517202633.GA14413@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Iyappan Subramanian <isubramanian@apm.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>,
        linux-arm-kernel@lists.infradead.org, patches <patches@apm.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34203 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751155AbdEREju (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 00:39:50 -0400
Received: by mail-pg0-f43.google.com with SMTP id u28so16872288pgn.1
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 21:39:49 -0700 (PDT)
In-Reply-To: <20170517202633.GA14413@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 3:26 AM, Andrew Lunn <andrew@lunn.ch> wrote:
>> +bool is_xgene_enet_phy_mode_rgmii(struct net_device *ndev)
>> +{
>> +     struct xgene_enet_pdata *pdata = netdev_priv(ndev);
>> +     int phy_mode = pdata->phy_mode;
>> +     bool ret;
>> +
>> +     ret = phy_mode == PHY_INTERFACE_MODE_RGMII ||
>> +           phy_mode == PHY_INTERFACE_MODE_RGMII_ID ||
>> +           phy_mode == PHY_INTERFACE_MODE_RGMII_RXID ||
>> +           phy_mode == PHY_INTERFACE_MODE_RGMII_TXID;
>> +
>> +     return ret;
>> +}
>
> include/linux/phy.h:
>
> /**
>  * phy_interface_is_rgmii - Convenience function for testing if a PHY interface
>  * is RGMII (all variants)
>  * @phydev: the phy_device struct
>  */
> static inline bool phy_interface_is_rgmii(struct phy_device *phydev)
> {
>         return phydev->interface >= PHY_INTERFACE_MODE_RGMII &&
>                 phydev->interface <= PHY_INTERFACE_MODE_RGMII_TXID;
> };
>

Hi Andrew,

Our purpose is to handle our internal pdata->phy_mode, so
phy_interface_is_rgmii(phydev) seems not to fit.
Instead, we're working on the below:

+bool is_xgene_enet_phy_mode_rgmii(struct net_device *ndev)
+{
+       struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+
+       return pdata->phy_mode >= PHY_INTERFACE_MODE_RGMII &&
+              pdata->phy_mode <= PHY_INTERFACE_MODE_RGMII_TXID;
+}
+
