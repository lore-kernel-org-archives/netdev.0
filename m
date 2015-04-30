From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 3/8] net: phy: Allow PHY devices to identify
 themselves as Ethernet switches
Date: Thu, 30 Apr 2015 19:16:30 +0200
Message-ID: <20150430171630.GE18874@lunn.ch>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
 <1430359064-23454-4-git-send-email-f.fainelli@gmail.com>
 <20150430125658.GB22831@lunn.ch>
 <55425AB3.2040908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44842 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751132AbbD3RVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 13:21:09 -0400
Content-Disposition: inline
In-Reply-To: <55425AB3.2040908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Hi Florian
> > 
> > I have another two use cases for fixed_phy which i'm thinking about
> > implementing soon. Both require putting a fixed_phy into DSA port
> > properties in DT.
> > 
> > The first is when the CPU ethernet and the switch don't have the same
> > speed capabilities. At the moment, the switch driver configures the
> > CPU port to its maximum speed. But i know of a board coming soon with
> > gigabit switch ports, but the CPU Ethernet is only fast Ethernet.
> 
> With the patch after, if your switch is MDIO connected to your host, you
> could make that happen easily, since the read_status() callback would
> only be invoked for the CPU port from the CPU Ethernet MAC driver
> (that's the theory).

I'm not sure i get what you are saying.

What we currently have is:

CPU ETH->fixed_phy                      Switch port CPU
|                                       |
+---------------------------------------+

and what i'm thinking we want is:

CPU ETH->fixed_phy          fixed_phy <-Switch port CPU
|                                       |
+---------------------------------------+

So that when setting up the switch side of the link, i can read from
the switch ports fixed_phy how the port should be configured.

I'm also wondering if they could even share one fixed_phy? 
But i suspect that will not work.

> > So in this respect, i'm wondering if is_switch is the best of names?
> 
> Probably not, I agree, pseudo_fixed_link ;)?

Yes, something like that.

     Andrew
