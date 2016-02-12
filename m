From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Fri, 12 Feb 2016 18:18:29 +0100
Message-ID: <20160212171829.GD13273@lunn.ch>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
 <56BD40F1.2030707@gmail.com>
 <20160212072040.GC8046@lunn.ch>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EF5BB@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, davem@davemloft.net, netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45236 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752262AbcBLRSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 12:18:32 -0500
Content-Disposition: inline
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EF5BB@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> At this point my plan is to just get a basic Ethernet controller
> driver submitted, and later work on switch features.

They are not really separable. 

The linux way of dealing with switches is to model each port as a net
device. So you should have a lan0 device and a lan1 device for this
two port switch. You can put IP addresses on the ports, and use them
as separate ports. If you want to bridge the two ports, you create a
linux bridge and add the ports to the bridge. Using netdev or DSA, you
can then push this configuration down to the hardware, so it performs
the actual bridging of packets between ports.

    Andrew
