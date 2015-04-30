From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 0/8] net: dsa: New registration API
Date: Thu, 30 Apr 2015 20:14:12 +0200
Message-ID: <20150430181412.GC1476@lunn.ch>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
 <20150430131216.GC22831@lunn.ch>
 <55425D5C.1020101@gmail.com>
 <20150430172726.GF18874@lunn.ch>
 <55426B7D.90207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44920 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751640AbbD3SSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 14:18:53 -0400
Content-Disposition: inline
In-Reply-To: <55426B7D.90207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I thought about this for a while, and came to the conclusion that it
> > is often a software construct, but it can also be a hardware
> > construct, when you have two ethernet interfaces connected to a
> > switch, all on one PCB. So i added a DT binding for bonding. In the
> > case of WRT1900AC, it looks like:
> > 
> >        bond: bond {
> >                compatible = "linux,bond";
> >                slaves = < &eth0 >, < &eth1 >;
> >        };
> 
> It seems to me that what we would want to represent here, is strictly
> the two "CPU" MACs mapping to their respective ports of the switch
> (assuming they are on different ports, right?).

Yes, different ports.
 
> Then whether they are part of a bond, such that you can utilize the full
> Wi-Fi throughput, is left to the user to configure that.
> 
> For instance, on the Linksys EA4500 I use for prototyping, there are two
> mv643xx_eth instances connected to a LAN-facing 4 ports group, and the
> other to the WAN, port 5 of the switch, this is similar to Mathieu's use
> case I believe, and whether we want to have a WAN/LAN separation, or
> have the two MACs participate in a LAN or WAN bond should be
> user-configurable.

Think about how you configure that today using DSA? You somehow need
to tell the switch that it should not use port 5, leave it enabled but
dumb, and the same for the second CPU port.

Bonding actually makes this simpler. With DSA you have your lan0-lan3
interfaces, and your wan0 interface. These are logically separate. You
then create a bridge, enslave lan0-lan3, and let the new hardware
offloading of bridging do the work.

> 
> By the same token, we could create bridges for ports 0-3 aka LAN
> directly from Device Tree ;)
> 
> > 
> > and then in DSA i have a phandle to this bond interface. This part
> > works great, but i've not posted these patches yet, because it does
> > not work yet because of some other issue. Maybe when i do post this,
> > it will get shot down?
> 
> I suppose you could post the patches and we look at this from there?

Well, i want to wait until it actually works. Having two CPU ports is
not mentioned in anywhere in the Marvell SDK.

    Andrew
