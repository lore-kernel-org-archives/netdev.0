From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: 3.0.0rc6: ethtool not working without a cable
Date: Wed, 06 Jul 2011 16:26:50 +0100
Message-ID: <1309966010.2712.4.camel@bwh-desktop>
References: <201107061338.08573.a.miskiewicz@gmail.com>
	 <1309962484.4280.25.camel@localhost>
	 <201107061653.04689.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:2143 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752979Ab1GFP0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 11:26:54 -0400
In-Reply-To: <201107061653.04689.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-07-06 at 16:53 +0200, Arkadiusz Miskiewicz wrote:
> On Wednesday 06 of July 2011, Ben Hutchings wrote:
> > On Wed, 2011-07-06 at 13:38 +0200, Arkadiusz Miskiewicz wrote:
> > > 3.0.0rc6, thinkpad t400 notebook.
> > > 
> > > If there is no cable then ethtool reports no device. It wasn't that
> > > before AFAIK.
> > > 
> > > ethtool version 2.6.36
> > > 
> > > 
> > > cable disconnected:
> > > 
> > > [root@t400 ~]# ethtool eth0
> > > Settings for eth0:
> > > Cannot get device settings: No such device
> > > Cannot get wake-on-lan settings: No such device
> > > Cannot get message level: No such device
> > > Cannot get link status: No such device
> > > No data available
> > > zsh: exit 75    ethtool eth0
> > > [root@t400 ~]# ethtool -i eth0
> > > Cannot get driver information: No such device
> > > zsh: exit 71    ethtool -i eth0
> > 
> > [...]
> > 
> > Then there really isn't a device under that name.  Maybe the driver is
> > getting a bogus MAC address, so that the device is renamed by udev.
> 
> No, no, device exists:
> 
> [arekm@t400 ~]$ ip l
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> 2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state 
> DOWN qlen 1000
>     link/ether 00:21:86:a2:19:06 brd ff:ff:ff:ff:ff:ff
> 3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc sfq state UP qlen 
> 1000
>     link/ether 00:16:eb:05:5d:08 brd ff:ff:ff:ff:ff:ff
> [arekm@t400 ~]$ ethtool eth0
> Settings for eth0:
> Cannot get device settings: No such device
> Cannot get wake-on-lan settings: No such device
> Cannot get message level: No such device
> Cannot get link status: No such device
> No data available
> zsh: exit 75    ethtool eth0
> [arekm@t400 ~]$

Then the only other explanation I can think of is that the driver has
'detached' the device due to some kind of error.  The ethtool core does
have a check for that.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

