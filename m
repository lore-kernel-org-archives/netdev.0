From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v0 00/10] Convert Netgear WNR854T to devicetree
Date: Sat, 16 Jul 2016 22:53:04 +0200
Message-ID: <20160716205304.GA5075@lunn.ch>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Cooper <jason@lakedaemon.net>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Imre Kaloz <kaloz@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Jamie Lentin <jm@lentin.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44070 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751712AbcGPUxR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jul 2016 16:53:17 -0400
Content-Disposition: inline
In-Reply-To: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There's one major flaw; unicast traffic is never received on any port.
> Broadcast traffic is received however, and on the correct port. Thus
> an external machine can make an ARP request and get a response, for
> example. With a manually-entered ARP entry, the router can send pings
> out to a remote machine which responds, and the response is lost in the
> DSA switch. "ethtool -S" reports pings received on "in_unicast" but
> nothing makes it through the switch. This thread[0] seems very similar.
> I've run out of ideas here and can't find any switch datasheets to give
> me pointers so any suggestions greatly appreciated.

Hi Jamie

So it is 6131? So part of the 6185 family. 

I see you have NET_TAG_DSA, but not NET_TAG_EDSA in your
configuration. Try swapping to EDSA. I even removed support for
TAG_DSA in one of the recent patches.

Please also can you get https://github.com/vivien/linux.git commit
323321875671dfe95b6b91ce051a74d415c7158c which will give you some
extra debug files /sys/kernel/debug/mv88e6xxx. 

The reg, stats, and atu would be interesting.

    Andrew
