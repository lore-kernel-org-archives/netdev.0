From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [patch 1/3] [PATCH] qeth: HiperSockets Network Traffic Analyzer
Date: Tue, 12 Jan 2010 13:25:31 +0100
Message-ID: <1263299131.6037.44.camel@braunu-laptop>
References: <1263295184.6037.26.camel@braunu-laptop>
	 <20100112.032305.223871701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	frank.blaschka@de.ibm.com, ursula.braun@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:41848 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083Ab0ALMZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 07:25:34 -0500
In-Reply-To: <20100112.032305.223871701.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-01-12 at 03:23 -0800, David Miller wrote:
> From: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Date: Tue, 12 Jan 2010 12:19:44 +0100
> 
> > An HS NTA device in Linux on System z is a specialized HiperSockets
> > device managed by the qeth driver and initialized specifically for
> > sniffing. The trigger for an HS device to act as a Network Traffic
> > Analyzer is the sysfs attribute "sniffer". If this attribute is set to
> > 1, the NTA-specific initialization is started when the HS device is
> > brought online. Traffic sniffing starts, once the device is switched
> > into promiscuous mode, for instance by invoking the tcpdump-tool.
> 
> Sounds like something which might be useful for other
> virtualized environments.
> 
> At worst, they would be able to provide some similar
> facility, and therefore the configuration mechanism to
> turn this on should be unified.
> 
> Perhaps an ethtool boolean flag setting or similar,
> rather than a baroque and driver specific sysfs knob.

Sounds like a good idea, but there exists a qeth-specific problem if
sniffer configuration should be switched to ethtool: Ethtool requires
the existence of the network interface for the network device. The
network interface for s390 network devices is defined within an
s390-specific initialization step called "online setting". The sniffing
characteristic must be configured before the online setting of the
device, since NTA-specific initialization steps are necessary. At that
point of time we cannot make use of ethtool, because the network
interface name is not known yet. That means switching to your proposed
ethtool-based configuration mechanism for HS NTA would result in an
additional major rework of qeth device setup.


