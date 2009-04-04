From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000: fix loss of multicast packets
Date: Sat, 04 Apr 2009 16:37:18 -0700 (PDT)
Message-ID: <20090404.163718.191996887.davem@davemloft.net>
References: <20090403020030.25363.85273.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com, daveboutcher@gmail.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42978
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754090AbZDDXha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2009 19:37:30 -0400
In-Reply-To: <20090403020030.25363.85273.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 02 Apr 2009 19:00:32 -0700

> e1000 (and e1000e, igb, ixgbe, ixgb) all do a series of
> operations each time a multicast address is added.  The flow goes
> something like
> 
> 1) stack adds one multicast address
> 2) stack passes whole current list of unicast and multicast
>    addresses to driver
> 3) driver clears entire list in hardware
> 4) driver programs each multicast address using iomem in a loop
> 
> This was causing multicast packets to be lost during the
> reprogramming process.
> 
> reference with test program:
> http://kerneltrap.org/mailarchive/linux-netdev/2009/3/14/5160514/thread
> 
> Thanks to Dave Boutcher for his report and test program.
> 
> This driver fix prepares an array all at once in memory and
> programs it in one shot to the hardware, not requiring an "erase"
> cycle.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
