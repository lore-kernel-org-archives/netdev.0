From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/7] net: dsa: add QCA AR8xxx switch family support
Date: Fri, 29 May 2015 04:00:01 +0200
Message-ID: <20150529020001.GF11260@lunn.ch>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	davem@davemloft.net, f.fainelli@gmail.com, linux@roeck-us.net,
	gang.chen.5i5j@gmail.com, jiri@resnulli.us, leitec@staticky.com,
	fabf@skynet.be, alexander.h.duyck@intel.com,
	pavel.nakonechny@skitlab.ru, joe@perches.com, sfeldma@gmail.com,
	nbd@openwrt.org, juhosg@openwrt.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mathieu Olivari <mathieu@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43459 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754169AbbE2CFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 22:05:38 -0400
Content-Disposition: inline
In-Reply-To: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 06:42:15PM -0700, Mathieu Olivari wrote:
> This patch set adds initial support for AR8xxx switches using the DSA
> subsystem. It currently supports QCA8337 switch, and can be extended to
> other hardware in the same family.
> 
> This switch was already discussed in the following thread:
> https://www.marc.info/?t=142601417400004&r=1&w=2
> 
> Below is a typical picture of a QCA8337 used in a standard home gateway
> configuration:
> 
> 	+-----------+       +-----------+
> 	|           | SGMII |           |
> 	|       eth0+-------+           +------ 1000baseT MDI ("WAN")
> 	|        wan|       |  7-port   +------ 1000baseT MDI ("LAN1")
> 	|   CPU     |       |  ethernet +------ 1000baseT MDI ("LAN2")
> 	|           | RGMII |  switch   +------ 1000baseT MDI ("LAN3")
> 	|       eth1+-------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
> 	|        lan|       |           |
> 	+-----------+       +-----------+
> 	          |   MDIO     |
> 	          \------------/
> 
> The switch is connected to the CPU using 2 xMII interfaces. As DSA only
> supports one logical interface to the switch, we split the switch using
> device-tree information into 2 parts:
> *port 6 (one of the xMII switch port) will be dedicated to one
>  particular Ethernet port. From a system perspective, it will be seen as
>  a regular PHY.
> *port 0 (the other xMII port) will act as the switch master interface

FYI:

I have patches which allow DSA to use two cpu interfaces. Seems to
work on my DIR665 with a Marvell Switch.

I will post the patches as an RFC.

  Andrew
