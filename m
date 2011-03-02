From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-rhine: do not abort due to invalid MAC address
Date: Wed, 02 Mar 2011 11:36:10 -0800 (PST)
Message-ID: <20110302.113610.71137356.davem@davemloft.net>
References: <20110302163233.GA14491@core.hellgate.ch>
	<201103021901.39849.florian@openwrt.org>
	<4D6E883C.2000800@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, rl@hellgate.ch, netdev@vger.kernel.org
To: mr.nuke.me@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56255
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754456Ab1CBTfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 14:35:33 -0500
In-Reply-To: <4D6E883C.2000800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alex G." <mr.nuke.me@gmail.com>
Date: Wed, 02 Mar 2011 20:11:08 +0200

> On 03/02/2011 08:01 PM, Florian Fainelli wrote:
>> 
>> Why not generate a valid random ethernet address using random_ether_addr() 
>> instead?
> 
> That would confuse ifcfg-* scripts that specify HWETHER, and probably
> users as well. It might even stump udev.

If the ethernet address reported by the card is garbage, every single
ethernet driver that tried to handle this case uses a random ethernet
address.

There is no reason to choose a different strategy for this driver.

Also registering a network device with an invalid ethernet address can
cause all kinds of serious issues, let's say dhcp brings the device
up and emits DHCP requests with illegal MAC addresses in the header
because of this problem.

You therefore simply cannot leave crap in there.
