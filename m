From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: "ADDRCONF(NETDEV_UP): eth0: link is not ready" with IPv6
Date: Fri, 29 Jun 2012 16:24:33 +0100
Message-ID: <1340983473.3066.6.camel@bwh-desktop.uk.solarflarecom.com>
References: <4FED14C2.9020200@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Arvid Brodin <Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48429 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755710Ab2F2PYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 11:24:39 -0400
In-Reply-To: <4FED14C2.9020200@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-29 at 02:36 +0000, Arvid Brodin wrote:
> Hi,
> 
> After 'ip link set eth0 up' on an avr32 board (network driver macb), the device ends up in
> operational mode "UNKNOWN":
> 
> # ip link
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
>     link/ether 00:24:74:00:17:9d brd ff:ff:ff:ff:ff:ff
> 
> Unplugging and plugging in the network cable gets the device to mode "UP".
> 
> This is a problem for me because I'm trying to use this device as a "slave" device (for a
> virtual HSR device*) and I need to be able to decide if the slave device is operational or
> not.
> 
> Following Stephen's advice here:
> http://kerneltrap.org/mailarchive/linux-netdev/2008/9/24/3398834 I checked the macb.c code
> and noticed they do not call netif_carrier_off() neither before register_netdev() nor in
> dev_open().

It should be called after register_netdev() and before the driver's
ndo_open implementation returns.

> I added the call before register_netdev(), which fixed the problem. However, if I then
> enable IPv6:
>
> # ip link set eth0 up
> ADDRCONF(NETDEV_UP): eth0: link is not ready
> eth0: link up (100/Full)
> ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

This looks normal.

> Any idea what is happening / what I'm doing wrong? (This is not just cosmetic; is some
> situations this seems to kill the interface - e.g. ping does not work, down/up does not
> help...) Things work fine without IPv6 configured.

Perhaps some packets sent automatically by IPv6 are triggering a driver
bug?  Or there is a bug in multicast support, which IPv6 always uses.

Ben.

> *N.B. I'm writing a driver for a network protocol called "High-availability Seamless
> Redundancy".

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
