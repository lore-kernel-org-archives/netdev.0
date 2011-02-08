From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 03/16] e1000e: do not wakeup Tx queue until ready
Date: Tue, 08 Feb 2011 12:21:15 -0800 (PST)
Message-ID: <20110208.122115.183054158.davem@davemloft.net>
References: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1297168167-15755-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bruce.w.allan@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48038
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754212Ab1BHUUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 15:20:40 -0500
In-Reply-To: <1297168167-15755-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  8 Feb 2011 04:29:14 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> When restarting the adapter via calls to e1000e_down() followed by
> e1000e_up() (for example when restarting autonegotiation via ethtool),
> packets can be queued for transmit before link is actually up and
> netif_carrier_on is set.  This was causing the watchdog_task to do an
> extra unnecessary reset of the adapter.  Delaying the wakeup of the Tx
> queue until link is up prevents the reset.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

You should not control the TX queue based upon link status information.
That's the job of netif_carrier_{on,off}().

The TX queue state should be set based solely upon that state of the
TX ring, whether it is full or not.

When the netif carrier is off, the packet scheduler is blocked from
sending packets to the driver.

If that isn't happening, that's a bug which you need to track down.
Maybe you're not doing netif_carrier_off() early enough.
