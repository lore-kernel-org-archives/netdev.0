From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: phy: Fix lack of reference count on PHY driver
Date: Wed, 1 Feb 2017 18:55:32 -0800
Message-ID: <eac63c36-2da2-fc5d-5363-67ef5d8169a1@gmail.com>
References: <20170201024643.2050-1-f.fainelli@gmail.com>
 <20170201102208.GM27312@n2100.armlinux.org.uk>
 <20170201105121.GA8191@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
        Mao Wenan <maowenan@huawei.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35109 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750776AbdBBCzf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 21:55:35 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so317226pfa.2
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 18:55:35 -0800 (PST)
In-Reply-To: <20170201105121.GA8191@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2017 02:51 AM, Russell King - ARM Linux wrote:
> It looks to me as if that's the only case where this can happen, so maybe
> the above needs to be:
> 
>         if (phydev->drv && phydev->drv->link_change_notify)
>                 phydev->drv->link_change_notify(phydev);
> 
> Also, I'd suggest making sure that the workqueue is flushed in
> phy_remove() after setting phydev->drv to NULL to ensure that the
> workqueue isn't running while the phy driver is being unbound, which
> should also make module removal safe(r).  I haven't fully analysed
> that though.

I suspect nobody has actually ever tested that, because it's pretty
badly broken at the moment... working on it.
-- 
Florian
