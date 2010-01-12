From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [patch 1/3] [PATCH] qeth: HiperSockets Network Traffic Analyzer
Date: Tue, 12 Jan 2010 14:29:24 +0100
Message-ID: <1263302964.6037.54.camel@braunu-laptop>
References: <1263295184.6037.26.camel@braunu-laptop>
	 <20100112.032305.223871701.davem@davemloft.net>
	 <1263299131.6037.44.camel@braunu-laptop>
	 <20100112.045944.197636957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	frank.blaschka@de.ibm.com, ursula.braun@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:55963 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773Ab0ALN31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 08:29:27 -0500
In-Reply-To: <20100112.045944.197636957.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-01-12 at 04:59 -0800, David Miller wrote:
> From: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Date: Tue, 12 Jan 2010 13:25:31 +0100
> 
> > Sounds like a good idea, but there exists a qeth-specific problem if
> > sniffer configuration should be switched to ethtool: Ethtool requires
> > the existence of the network interface for the network device. The
> > network interface for s390 network devices is defined within an
> > s390-specific initialization step called "online setting". The sniffing
> > characteristic must be configured before the online setting of the
> > device, since NTA-specific initialization steps are necessary. At that
> > point of time we cannot make use of ethtool, because the network
> > interface name is not known yet. That means switching to your proposed
> > ethtool-based configuration mechanism for HS NTA would result in an
> > additional major rework of qeth device setup.
> 
> If you have a place to stick sysfs nodes, you've obviously
> instantiated the device already.

I should have been more precise: In the s390-world there are 2 steps for
network device setup - a ccwgroup-step, which establishes the "struct
device", and an online-step, which establishes the "struct net_device".
After the ccwgroup-step we have an instantiated device and can make use
of sysfs. After the online-step, we have an instantiated net_device
incl. network interface name and can make use of ethtool. HiperSockets
sniffer configuration is required before the online-step.

