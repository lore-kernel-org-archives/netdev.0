From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 1/3] Documentation: devicetree: add multiple cpu port
 DSA binding
Date: Thu, 8 Jun 2017 21:31:12 +0200
Message-ID: <20170608193112.GF20216@lunn.ch>
References: <20170530104419.6052-1-john@phrozen.org>
 <69dd02a6-59f9-59df-f630-0ebd948451c4@gmail.com>
 <20170607211002.ubljfplyexjb6dyl@rob-hp-laptop>
 <64218746-fbb6-f958-ba15-5ed704214d25@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh@kernel.org>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <64218746-fbb6-f958-ba15-5ed704214d25@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Right now we don't have any mechanism, and statically doing this from
> Device Tree is too inflexible. I have been working on a parallel path
> where we use the bridge (which is already accelerated when there is a
> switch) in order to define groups of ports, the idea would be do to e.g:
> 
> brctl addbr br-lan
> brctl addbr br-lan eth0
> brctl addbr br-lan lan1
> ...
> brctl addbr br-lan lan4
> 
> brctl addbr br-wan
> brctl addbr br-wan eth1
> brctl addbr br-wan wan
> 
> Assuming that lan1-lan4 are your LAN ports, and wan is your WAN port and
> you have two CPU ports.

Hi Florian

I don't like this, on multiple levels.

My wan port typically never has more than 40Mbps of traffic on it. So
dedicating a whole 1Gbps ethernet to it makes no sense. I want to
share eth1 bandwidth with the wan port, and some of the other
ports. Meaning i would have to add eth1 to br-lan as well as
br-wan. Does the bridge allow that? And what sort of hacks do you have
to allow a port to be added to a bridge, but not used by the bridge?

And what is the point of br-wan? It only has one real port in it. So
i'm adding per-packet overhead which i don't need, just in order to
signal to the hardware how it should statically route cpu traffic for
a port.

Now say i have one of the bigger marvell switches, with 11 ports, in
an industrial application. I setup 3 or 4 bridges. I then need to add
eth0 and eth1 to two different bridges. And say i use some ports
without a bridge. How do i configure them?

And how do i dump the current mapping?

For me, this is the wrong architecture. What CPU port is used should
be a port property, not a bridge property. I think we should use
devlink. Add commands to dump the current mapping, and set it.

	 Andrew
