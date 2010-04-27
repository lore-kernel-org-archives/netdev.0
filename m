From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: ixgbe_down needs to stop
 dev_watchdog
Date: Tue, 27 Apr 2010 12:56:11 -0700 (PDT)
Message-ID: <20100427.125611.186318761.davem@davemloft.net>
References: <20100427121300.25038.2341.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	john.r.fastabend@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49607
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756799Ab0D0T4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 15:56:06 -0400
In-Reply-To: <20100427121300.25038.2341.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Apr 2010 05:13:39 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> There is a small race between when the tx queues are stopped
> and when netif_carrier_off() is called in ixgbe_down.  If the
> dev_watchdog() timer fires during this time it is possible for
> a false tx timeout to occur.
> 
> This patch moves the netif_carrier_off() so that it is called before
> the tx queues are stopped preventing the dev_watchdog timer from
> detecting false tx timeouts.  The race is seen occosionally when
> FCoE or DCB settings are being configured or changed.
> 
> Testing note, running ifconfig up/down will not reproduce this
> issue because dev_open/dev_close call dev_deactivate() and then
> dev_activate().
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
