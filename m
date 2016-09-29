From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 5/6] net: phy: Trigger state machine on state change
 and not polling.
Date: Thu, 29 Sep 2016 09:08:40 +0200
Message-ID: <20160929070840.GB7234@lunn.ch>
References: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
 <1475051544-18561-6-git-send-email-andrew@lunn.ch>
 <de3b7050-4346-1a7a-4a27-feb8bb8affc4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35721 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932301AbcI2HIp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Sep 2016 03:08:45 -0400
Content-Disposition: inline
In-Reply-To: <de3b7050-4346-1a7a-4a27-feb8bb8affc4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2016 at 02:31:54PM -0700, Florian Fainelli wrote:
> On 09/28/2016 01:32 AM, Andrew Lunn wrote:
> > The phy_start() is used to indicate the PHY is now ready to do its
> > work. The state is changed, normally to PHY_UP which means that both
> > the MAC and the PHY are ready.
> > 
> > If the phy driver is using polling, when the next poll happens, the
> > state machine notices the PHY is now in PHY_UP, and kicks off
> > auto-negotiation, if needed.
> > 
> > If however, the PHY is using interrupts, there is no polling. The phy
> > is stuck in PHY_UP until the next interrupt comes along. And there is
> > no reason for the PHY to interrupt.
> > 
> > Have phy_start() schedule the state machine to run, which both speeds
> > up the polling use case, and makes the interrupt use case actually
> > work.
> > 
> > This problems exists whenever there is a state change which will not
> > cause an interrupt. Trigger the state machine in these cases,
> > e.g. phy_error().
> > 
> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> 
> No particular objections, this should also fix this:
> 
> http://lists.openwall.net/netdev/2016/05/17/147

Hi Florian

Yes, i was thinking it probably should have a fixes: tag and be a
separate patch. The hard part will be figuring out when this actually
broke, or does it go all the way back to when interrupt support was
added?

	Andrew
