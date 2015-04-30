From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 0/8] net: dsa: New registration API
Date: Thu, 30 Apr 2015 19:27:26 +0200
Message-ID: <20150430172726.GF18874@lunn.ch>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
 <20150430131216.GC22831@lunn.ch>
 <55425D5C.1020101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44858 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbbD3RcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 13:32:05 -0400
Content-Disposition: inline
In-Reply-To: <55425D5C.1020101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2015 at 09:50:36AM -0700, Florian Fainelli wrote:
> On 30/04/15 06:12, Andrew Lunn wrote:
> >> Note that there are currenlty no incompatibles changes made to existing Device
> >> Tree sources, rather, depending on the bus we are probed for, e.g: MDIO
> >> the dsa,mii-bus and dsa,ethernet phandles and first cell of the  "reg" property
> >> will become obsolete, everything else remains entirely compatible. 
> > 
> > Hi Florian
> > 
> > I'm not sure dsa,mii-bus and dsa,ethernet will become obsolete. At
> > least they are probably needed for multi switch setups, and the
> > possible but probably unlikely multi DSA setups.
> > 
> > You cannot assume that dsa,mii-bus and dsa,ethernet have the same
> > parent. In a multi switch setup, it could be there is an mdio-mux in
> > the picture. So all your probe really tells you, is that there is a
> > switch on this mii bus, but you don't know what ethernet it is hanging
> > off.
> 
> Good point.
> 
> > 
> > The switch could be hanging off multiple ethernets. I'm working on
> > supporting this for the WRT1900AC, where i use the bond driver on the
> > host side. So dsa,ethernet is a phandle to a bond interface.
> 
> Humm, bond is a software constructs,

I thought about this for a while, and came to the conclusion that it
is often a software construct, but it can also be a hardware
construct, when you have two ethernet interfaces connected to a
switch, all on one PCB. So i added a DT binding for bonding. In the
case of WRT1900AC, it looks like:

       bond: bond {
               compatible = "linux,bond";
               slaves = < &eth0 >, < &eth1 >;
       };

and then in DSA i have a phandle to this bond interface. This part
works great, but i've not posted these patches yet, because it does
not work yet because of some other issue. Maybe when i do post this,
it will get shot down?

     Andrew
