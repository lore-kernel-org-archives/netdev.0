From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: RFC: dsa: add support for multiple CPU ports
Date: Tue, 10 Mar 2015 22:13:15 +0100
Message-ID: <20150310211315.GF10838@lunn.ch>
References: <20150310190129.GB5636@codeaurora.org>
 <20150310193151.GE10838@lunn.ch>
 <20150310204021.GA2740@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux@roeck-us.net, jogo@openwrt.org,
	f.fainelli@gmail.com
To: Mathieu Olivari <mathieu@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57141 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280AbbCJVQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 17:16:36 -0400
Content-Disposition: inline
In-Reply-To: <20150310204021.GA2740@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I was thinking about the MIB counters, maintained by the switch, on the CPU
> port(s). 
> 
> On this picture:
> 
> +-----------+       +--------------------+
> |           | RGMII |                    |
> |       eth0+-------+ P0              P1 +------ 1000baseT MDI ("WAN")
> |        wan|       |      7-port     P2 +------ 1000baseT MDI ("LAN1")
> |   CPU     |       |      ethernet   P3 +------ 1000baseT MDI ("LAN2")
> |           | RGMII |      switch     P4 +------ 1000baseT MDI ("LAN3")
> |       eth1+-------+ P6   w/5 PHYs   P5 +------ 1000baseT MDI ("LAN4")
> |        lan|       |                    |
> +-----------+       +--------------------+
>           |     MDIO   |
>           \------------/
> 
> We can see MIB stats of P1/P2/P3/P4/P5 by using ethtool -S. But as CPU
> ports don't have a net_device, there isn't a way to access MIB stats of
> P0 & P6.

Ah, sorry, i misunderstood you. As you say, the current DSA does not
give you access to these counters. Apart from these counters, are
there any other needs to have access to these ports? The core idea of
hardware acceleration is that it should look like linux as normal.  P0
and P6 are an internal detail, and you cannot actually use them. You
cannot send packets, they are something special. So unless there is a
good reason, we should not expose them.

> If we have the eth0 <--> P0 and eth1 <--> P6 relationship information in dts,
> we could use it to lookup which switch port is connected to this net_dev and
> show the corresponding counters when running "ethtool -S ethN".

But that is not what the user expects. They expect the statistic
counters for ethN, not the switch port.

	 Andrew
