From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 24 May 2017 16:09:29 +0200
Message-ID: <20170524140929.GC26577@lunn.ch>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthias May <matthias.may@neratec.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        netdev@vger.kernel.org, f.fainelli@gmail.com,
        David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43099 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967371AbdEXOJc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 10:09:32 -0400
Content-Disposition: inline
In-Reply-To: <8cf4ca6d-3e1e-3c9c-605f-5d6baf3c7588@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 24, 2017 at 08:48:04AM -0500, Timur Tabi wrote:
> On 5/24/17 8:40 AM, Andrew Lunn wrote:
> 
> >You need to prove this, that the link is not up. Any by link, we mean
> >both the copper and the SGMII link.
> 
> I can post the log of my iperf run showing that the, when
> at803x_aneg_done() returns zero, no packets can go through.  And
> then after I change at803x_aneg_done() so that it returns
> BMSR_ANEGCOMPLETE, then packets do go through.  Is that the proof
> you're looking for?

No. I would like to see the status of the copper side and the status
of the SGMII side, at the point at803x_aneg_done() is called.

If the copper side is up, but the SGMII side is down, returning 0 is
correct.

> Exxactly.  That's because the link IS up, and so there is no
> opportunity to receive another interrupt.

It could be, the copper side is up, but the SGMII side is down, at the
point at803x_aneg_done() is called. So it is correctly returning
0. Sometime later the SGMII side goes up, but there is not a second
interrupt. Hence the phy core does not know that the full, 2 stage MAC
to PHY to peer PHY link is now up.

	Andrew
