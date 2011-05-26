From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Setting shutdownspeed in r8169 driver
Date: Thu, 26 May 2011 08:04:36 -0700
Message-ID: <1306422276.17233.87.camel@localhost>
References: <201105242302.40221.bas@tcfaa.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bas Nedermeijer <bas@tcfaa.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:47565 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630Ab1EZRFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 13:05:00 -0400
In-Reply-To: <201105242302.40221.bas@tcfaa.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-24 at 23:02 +0200, Bas Nedermeijer wrote:
> Hello,
> 
> I currently have an onboard nic, which allows me to use wake-on-lan. But link-
> speed goes to 10MBit when the system is shutdown. This causes a multicast/IPTV  
> stream to be throttled back to 10Mbit. This is probably because the multicast 
> stream actually a broadcast on my local network. I think some device is 
> sending ethernet-pause frames (havent seem them, but not sure if they show up 
> in tcpdump).

Pause frames are produced and consumed at the MAC control layer.  Some
switches may forward pause frames, but I suspect that in this case the
switch is sending pause frames to the multicast sender because the
transmit queue for the 10M port is filling up.

For hardware that supports Ethernet flow control, there are usually
pause frame counters in the extended statistics (ethtool -S).

> I tried to disable flow-control on the sending device, but that 
> didnt help, still the traffic is throttled when it has passed some switches. I 
> read somewhere the windows driver has an option to specify the shutdown-
> linkspeed, so listening for WOL happens on 100mbit. I was wondering if it is 
> possible at all with the linux-driver (maybe as default by modifying the 
> driver locally as I cant seem to find a userspace program to modify the 
> settings).

No, there is no such setting within the ethtool API for WOL
configuration on Linux.  It seems like it would be a useful extension.

Ben.

> I am using the driver "r8169"
> 
> According to 'lspci':
> 
> Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet 
> controller (rev 02)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

