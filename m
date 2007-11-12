From: Timur Tabi <timur@freescale.com>
Subject: Re: Problems with ULI 526x driver
Date: Mon, 12 Nov 2007 13:21:08 -0600
Message-ID: <4738A7A4.1030004@freescale.com>
References: <47389E72.7050907@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: peerchen@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:46978 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528AbXKLTVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 14:21:13 -0500
In-Reply-To: <47389E72.7050907@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Timur Tabi wrote:
> Hi,
> 
> I'm trying to get the ULI 526x driver working on a Freescale 8610 
> reference board, and it can't connect.  When I turn on debug, I see this:

Update: I can ping anything on my subnet, but nothing else.  Also, it looks like 
my MAC address is hosed:

eth0      Link encap:Ethernet  HWaddr 00:00:00:00:00:00
           inet addr:10.82.19.159  Bcast:10.82.19.255  Mask:255.255.255.0
           inet6 addr: fe80::200:ff:fe00:0/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:5 errors:0 dropped:0 overruns:0 frame:0
           TX packets:26 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:414 (414.0 b)  TX bytes:1224 (1.1 KiB)
           Interrupt:18 Base address:0x1000

It turns out that the driver is getting the MAC address from the ID table:

	if(((u16 *) db->srom)[0] == 0xffff || ((u16 *) db->srom)[0] == 0)		/* SROM 
absent, so read MAC address from ID Table */
	{


In my case, the address that is returned is all zeros.  I don't know anything 
about the ULI 526x hardware.  Is it possible that there's a missing EEPROM on my 
board that's supposed to hold the MAC address?  Are these registers user-writable?

-- 
Timur Tabi
Linux kernel developer at Freescale
