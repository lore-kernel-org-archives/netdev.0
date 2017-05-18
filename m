From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] drivers: net: xgene: Check all RGMII phy mode
 variants
Date: Thu, 18 May 2017 15:02:20 +0200
Message-ID: <20170518130220.GA32503@lunn.ch>
References: <1495051550-28961-1-git-send-email-isubramanian@apm.com>
 <20170517202633.GA14413@lunn.ch>
 <CAFopSPTP07TFcgc8pACQDF4ZXHOftUMBqBCgF4hVpAmUt0cCWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Iyappan Subramanian <isubramanian@apm.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>,
        linux-arm-kernel@lists.infradead.org, patches <patches@apm.com>
To: Quan Nguyen <qnguyen@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35468 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754620AbdERNCZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 09:02:25 -0400
Content-Disposition: inline
In-Reply-To: <CAFopSPTP07TFcgc8pACQDF4ZXHOftUMBqBCgF4hVpAmUt0cCWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Andrew,
> 
> Our purpose is to handle our internal pdata->phy_mode, so
> phy_interface_is_rgmii(phydev) seems not to fit.
> Instead, we're working on the below:
> 
> +bool is_xgene_enet_phy_mode_rgmii(struct net_device *ndev)
> +{
> +       struct xgene_enet_pdata *pdata = netdev_priv(ndev);
> +
> +       return pdata->phy_mode >= PHY_INTERFACE_MODE_RGMII &&
> +              pdata->phy_mode <= PHY_INTERFACE_MODE_RGMII_TXID;
> +}
> +

This is very generic, can could be used by other drivers. I prefer
what Florian suggested, have a generic helper which takes phy_mode as
a parameters. And then modify phy_interface_is_rgmii() to use this
helper.

	Andrew
