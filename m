From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 24 May 2017 13:58:09 -0500
Message-ID: <c2a54e2e-a1b6-24b4-d125-95fa9648fe95@codeaurora.org>
References: <20170522210927.GR29447@lunn.ch>
 <0d9b30e5-40f3-82ba-a44a-2eb25b8d3094@codeaurora.org>
 <20170522213206.GT29447@lunn.ch>
 <a8415b8b-1713-053d-41d3-2577c5a53c8b@codeaurora.org>
 <20170523160722.GC21169@lunn.ch>
 <3dc4f9cf-3172-0227-f03c-1ccfdad3e15e@codeaurora.org>
 <a87a7309-e15e-286f-08d0-83535c094358@neratec.com>
 <a88a111d-5e3a-0999-14ef-0ada06febb3f@codeaurora.org>
 <20170524134021.GA26577@lunn.ch>
 <8cf4ca6d-3e1e-3c9c-605f-5d6baf3c7588@codeaurora.org>
 <20170524140929.GC26577@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Matthias May <matthias.may@neratec.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        netdev@vger.kernel.org, f.fainelli@gmail.com,
        David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38332 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754524AbdEXS6L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 14:58:11 -0400
In-Reply-To: <20170524140929.GC26577@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2017 09:09 AM, Andrew Lunn wrote:
> It could be, the copper side is up, but the SGMII side is down, at the
> point at803x_aneg_done() is called. So it is correctly returning
> 0. Sometime later the SGMII side goes up, but there is not a second
> interrupt. Hence the phy core does not know that the full, 2 stage MAC
> to PHY to peer PHY link is now up.

Ok, I'm going to debug this some more.  It turns out that the MAC side of
the SGMII link can send an interrupt when it thinks that auto-negotiation is
done.  I might be able to use this.

What function should my MAC driver call when it wants the phy core to call
at803x_aneg_done again to see if autonegotiation is done?

Also, is there a way for the MAC driver to know that at803x_aneg_done()
previously returned 0, and that it needs to tell the phy core to check again?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
