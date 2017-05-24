From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 24 May 2017 15:40:21 +0200
Message-ID: <20170524134021.GA26577@lunn.ch>
References: <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
 <20170522210927.GR29447@lunn.ch>
 <0d9b30e5-40f3-82ba-a44a-2eb25b8d3094@codeaurora.org>
 <20170522213206.GT29447@lunn.ch>
 <a8415b8b-1713-053d-41d3-2577c5a53c8b@codeaurora.org>
 <20170523160722.GC21169@lunn.ch>
 <3dc4f9cf-3172-0227-f03c-1ccfdad3e15e@codeaurora.org>
 <a87a7309-e15e-286f-08d0-83535c094358@neratec.com>
 <a88a111d-5e3a-0999-14ef-0ada06febb3f@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthias May <matthias.may@neratec.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        netdev@vger.kernel.org, f.fainelli@gmail.com,
        David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43038 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1763507AbdEXNkZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 09:40:25 -0400
Content-Disposition: inline
In-Reply-To: <a88a111d-5e3a-0999-14ef-0ada06febb3f@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >Since aneg is mandatory for SGMII this can as well be seen as "link not up", not?
> 
> The problem is that even though the link is up, the driver has
> returned "0", so the kernel thinks that autonegotiation has not
> finished.

You need to prove this, that the link is not up. Any by link, we mean
both the copper and the SGMII link. 

> at803x_aneg_done() is never called again, and so I think
> the kernel is disabling the interface is some secret way.

Well, the driver has told the core that the link is not up. So the
kernel is waiting for another interrupt indicating the link has gone
up. And probably, this second interrupt never happens.

And it is not disabling the interface. Since the PHY is still down,
the core has not called netif_carrier_on().

    Andrew
