From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: 4.3.0+ breaks software VPN
Date: Fri, 13 Nov 2015 16:43:19 -0500
Message-ID: <20151113214319.GA9891@codemonkey.org.uk>
References: <564657FC.4050206@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarod Wilson <jarod@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <axboe@kernel.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:50767 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbbKMVnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 16:43:32 -0500
Content-Disposition: inline
In-Reply-To: <564657FC.4050206@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2015 at 02:37:00PM -0700, Jens Axboe wrote:
 > Hi,
 > 
 > Tried to connect to sw vpn today, and it isn't working. Running git 
 > as-of yesterday. In dmesg:
 > 
 > [23703.921542] vpn0: set_features() failed (-1); wanted 
 > 0x00000080000048c1, left 0x00000080001b48c9
 > 
 > Reverting:
 > 
 > fd867d51f889
 > 5ba3f7d61a3a
 > e7868a85e1b2
 > 
 > in reverse order makes it work again. How do we get this fixed so that 
 > 4.4-rc1 doesn't break basic VPN support?

Possibly related:
I see those set_features warnings have started spewing in my 2-nic bonding
setup too.

[   51.595169] Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
[   51.595647] bond0: set_features() failed (-1); wanted 0x000000000fc0f388, left 0x000000000fd9fbe9
[   51.597168] bond0: Setting MII monitoring interval to 100
[   51.600782] bond0: Adding slave eth0
[   51.831790] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   51.832078] bond0: set_features() failed (-1); wanted 0x000000000fd9fba9, left 0x000000000fd9fbe9
[   51.832190] bond0: Enslaving eth0 as an active interface with a down link
[   51.836657] bond0: Adding slave eth1
[   52.039515] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
[   52.039655] bond0: set_features() failed (-1); wanted 0x000000000fd9fba9, left 0x000000000fd9fbe9
[   52.039735] bond0: Enslaving eth1 as an active interface with a down link


	Dave
