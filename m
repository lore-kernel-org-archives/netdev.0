From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: RFC: dsa: add support for multiple CPU ports
Date: Wed, 11 Mar 2015 14:30:57 +0100
Message-ID: <20150311133057.GA9601@lunn.ch>
References: <20150310190129.GB5636@codeaurora.org>
 <20150310193151.GE10838@lunn.ch>
 <20150310204021.GA2740@codeaurora.org>
 <CAGVrzcZcLgMWuNJ9R_izuBRyyY21=ZJw+2Dk8RfxijGd2fMXNQ@mail.gmail.com>
 <20150311011802.GA10875@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Jonas Gorski <jogo@openwrt.org>
To: Mathieu Olivari <mathieu@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57646 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750770AbbCKNeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 09:34:22 -0400
Content-Disposition: inline
In-Reply-To: <20150311011802.GA10875@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We already have existing interface for eth0/eth1. Maybe we should
> consider allowing them to be bridge. User configuration would look like
> this:
> 
> brctl addbr br-lan
> brctl addif br-lan eth1
> brctl addif br-lan lan1
> brctl addif br-lan lan2
> brctl addif br-lan lan3
> brctl addif br-lan lan4

Think about this from the perspective of somebody how does not know
there is a switch.  When i look at this, to me it means packets from
lan1, lan2, lan3, lan4 and eth1 are bridged together. So we are going
to get packets sent out eth1 without a tag on it, and the switch is
very likely to drop it, since the port is in a mode which expects a
tag. You are not using the brctl command with its normal meaning,
which is bad.

Configuring this at the bridge layer is also wrong. What conduit a DSA
slave interfaces uses is a DSA layer issue.

Before we can come up with a nice solution, i think we first need to
understand what the switches are capable off. If trunking does work,
it is a relatively nice system for the user to configure, in that
there is nothing for the user to configure! Assuming the switch can do
reasonable load balancing, we also get near optimal usage of the two
conduits.

I don't know when i will have time to play with this, and if somebody
comes along with a better idea, i'm very open to adopting that idea
over mine.

      Andrew
