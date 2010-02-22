From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: prevent speculative processing of
 descriptors before ready
Date: Mon, 22 Feb 2010 15:49:13 -0800 (PST)
Message-ID: <20100222.154913.144379311.davem@davemloft.net>
References: <20100220034419.31030.5083.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, miltonm@bga.com,
	anton@samba.org, donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40929
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750801Ab0BVXsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 18:48:55 -0500
In-Reply-To: <20100220034419.31030.5083.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 19 Feb 2010 19:44:42 -0800

> From: Milton Miller <miltonm@bga.com>
> 
> The PowerPC architecture does not require loads to independent bytes to be
> ordered without adding an explicit barrier.
> 
> In ixgbe_clean_rx_irq we load the status bit then load the packet data.
> With packet split disabled if these loads go out of order we get a
> stale packet, but we will notice the bad sequence numbers and drop it.
> 
> The problem occurs with packet split enabled where the TCP/IP header and data
> are in different descriptors. If the reads go out of order we may have data
> that doesn't match the TCP/IP header. Since we use hardware checksumming this
> bad data is never verified and it makes it all the way to the application.
> 
> This bug was found during stress testing and adding this barrier has been shown
> to fix it.
> 
> Signed-off-by: Milton Miller <miltonm@bga.com>
> Signed-off-by: Anton Blanchard <anton@samba.org>
> Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
