From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 0/8] net: dsa: New registration API
Date: Thu, 30 Apr 2015 15:12:16 +0200
Message-ID: <20150430131216.GC22831@lunn.ch>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dave@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44616 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbbD3NQy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 09:16:54 -0400
Content-Disposition: inline
In-Reply-To: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Note that there are currenlty no incompatibles changes made to existing Device
> Tree sources, rather, depending on the bus we are probed for, e.g: MDIO
> the dsa,mii-bus and dsa,ethernet phandles and first cell of the  "reg" property
> will become obsolete, everything else remains entirely compatible. 

Hi Florian

I'm not sure dsa,mii-bus and dsa,ethernet will become obsolete. At
least they are probably needed for multi switch setups, and the
possible but probably unlikely multi DSA setups.

You cannot assume that dsa,mii-bus and dsa,ethernet have the same
parent. In a multi switch setup, it could be there is an mdio-mux in
the picture. So all your probe really tells you, is that there is a
switch on this mii bus, but you don't know what ethernet it is hanging
off.

The switch could be hanging off multiple ethernets. I'm working on
supporting this for the WRT1900AC, where i use the bond driver on the
host side. So dsa,ethernet is a phandle to a bond interface.

The probe is likely to find all switches in a multi switch setup. But
i guess we only want the probe of the root devices in a switch tree to
cause a DSA setup.

So i think there needs to be some matching performed when looking in
the device tree. The dsa,mii-bus and address discovered by probing
need to match what is in the DSA properties.

     Andrew
