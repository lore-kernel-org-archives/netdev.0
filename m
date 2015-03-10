From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: Re: RFC: dsa: add support for multiple CPU ports
Date: Tue, 10 Mar 2015 15:53:26 -0700
Message-ID: <20150310225326.GA12693@codeaurora.org>
References: <20150310190129.GB5636@codeaurora.org>
 <20150310193151.GE10838@lunn.ch>
 <20150310204021.GA2740@codeaurora.org>
 <20150310211315.GF10838@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux@roeck-us.net, jogo@openwrt.org,
	f.fainelli@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:49031 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273AbbCJWxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 18:53:31 -0400
Content-Disposition: inline
In-Reply-To: <20150310211315.GF10838@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2015 at 10:13:15PM +0100, Andrew Lunn wrote:
> > I was thinking about the MIB counters, maintained by the switch, on the CPU
> > port(s). 
> > 
> > On this picture:
> > 
> > +-----------+       +--------------------+
> > |           | RGMII |                    |
> > |       eth0+-------+ P0              P1 +------ 1000baseT MDI ("WAN")
> > |        wan|       |      7-port     P2 +------ 1000baseT MDI ("LAN1")
> > |   CPU     |       |      ethernet   P3 +------ 1000baseT MDI ("LAN2")
> > |           | RGMII |      switch     P4 +------ 1000baseT MDI ("LAN3")
> > |       eth1+-------+ P6   w/5 PHYs   P5 +------ 1000baseT MDI ("LAN4")
> > |        lan|       |                    |
> > +-----------+       +--------------------+
> >           |     MDIO   |
> >           \------------/
> > 
> > We can see MIB stats of P1/P2/P3/P4/P5 by using ethtool -S. But as CPU
> > ports don't have a net_device, there isn't a way to access MIB stats of
> > P0 & P6.
> 
> Ah, sorry, i misunderstood you. As you say, the current DSA does not
> give you access to these counters. Apart from these counters, are
> there any other needs to have access to these ports? The core idea of
> hardware acceleration is that it should look like linux as normal.  P0
> and P6 are an internal detail, and you cannot actually use them. You
> cannot send packets, they are something special. So unless there is a
> good reason, we should not expose them.
> 

That is true, but the switch does have information to share about this
port (stats). Having a standard way to retrieve this information would
be nice.

> > If we have the eth0 <--> P0 and eth1 <--> P6 relationship information in dts,
> > we could use it to lookup which switch port is connected to this net_dev and
> > show the corresponding counters when running "ethtool -S ethN".
> 
> But that is not what the user expects. They expect the statistic
> counters for ethN, not the switch port.

The user would probably want to access both. It should not replace ethN
counters obviously, but these are real switch port (just without any PHY),
so the user would want to have the same level of information as it has on
the other logical switch ports.

I was wondering whether it made sense to show counters for both ethN and
P0 when running "ethtool -S ethN". Or maybe add a new argument to
ethtool. Else, there is still debugfs but it means the same counters
will be accessible through ethtool (for PHY ports) and debugfs (for MAC
ports), which is not very consistent.

> 
> 	 Andrew
