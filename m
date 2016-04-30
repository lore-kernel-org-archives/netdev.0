From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: New DSA design for cross-chip operations
Date: Sat, 30 Apr 2016 23:38:18 +0200
Message-ID: <20160430213818.GA24762@lunn.ch>
References: <1570407369.390644.1461965624673.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53625 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257AbcD3ViW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Apr 2016 17:38:22 -0400
Content-Disposition: inline
In-Reply-To: <1570407369.390644.1461965624673.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 29, 2016 at 05:33:44PM -0400, Vivien Didelot wrote:
> Hi,
> 
> Here's a proposal for a new design of DSA. It is meant to discuss the
> actual state and future implementation of the D (for distributed) in
> DSA, which consists of supporting several interconnected switch chips,
> exposed to the user as one big switch unit.
> 
> There's still a lot of work to finish in DSA before running into
> cross-chip operations, but it'll help to start thinking about it now.

Hi Vivien

One thing we should keep in mind. Very few switch chips actually
support D in DSA. In fact, at the moment, i don't know of any other
than Marvell. The Broadcom SF2 does not. The Microchip LAN935X
don't. The Micrel KS8995 does not. Do any of the switches supported by
OpenWRT via swconfig?

We should try to limit adding complexity to the DSA core and the API
to the drivers which the majority of drivers will never need. I would
make use of the layering we already have. For the Marvell devices, add
a cross chip layer between the Marvell drivers and the DSA core. And
even then, we might want to keep this layer optional for Marvell
devices. There are only a few niche boards with multiple switch
chips. There are many more WiFi access points and cable modems, etc,
with just a single switch.

  Andrew
