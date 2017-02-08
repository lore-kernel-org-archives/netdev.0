From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net v2 1/3] net: phy: Fix PHY module checks
Date: Wed, 8 Feb 2017 14:46:13 -0200
Message-ID: <CAOMZO5COWf8Ojw=nF5JXv54AweK17sBAb+aYk7VCOoMcj1t8kQ@mail.gmail.com>
References: <20170208073746.10963-1-f.fainelli@gmail.com> <20170208073746.10963-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Russell King <rmk+kernel@armlinux.org.uk>, maowenan@huawei.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f193.google.com ([74.125.82.193]:33723 "EHLO
        mail-ot0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752563AbdBHQqQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:46:16 -0500
Received: by mail-ot0-f193.google.com with SMTP id f9so18576193otd.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 08:46:14 -0800 (PST)
In-Reply-To: <20170208073746.10963-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 8, 2017 at 5:37 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> The Generic PHY drivers gets assigned after we checked that the current PHY
> driver is NULL, so we need to check a few things before we can safely
> derference d->driver. Update phy_attach_direct() and phy_detach() accordingly
> to be resilient to these cases.
>
> Even though the Generic PHY driver defaults to phy_probe() which can hardly
> fail at the moment, let's fix the label so we don't call phy_detach() on a
> network device we have not attached yet.
>
> Fixes: cafe8df8b9bc ("net: phy: Fix lack of reference count on PHY driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

This fixes the kernel crash:

Tested-by: Fabio Estevam <fabio.estevam@nxp.com>
