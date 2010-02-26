From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: do not stop tx queues in
 ixgbe_set_tso
Date: Fri, 26 Feb 2010 02:10:44 -0800 (PST)
Message-ID: <20100226.021044.47249344.davem@davemloft.net>
References: <20100226091318.19796.70225.stgit@localhost.localdomain>
	<20100226091456.19796.53149.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	john.r.fastabend@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50657
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752561Ab0BZKK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 05:10:29 -0500
In-Reply-To: <20100226091456.19796.53149.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 26 Feb 2010 01:14:58 -0800

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> Disabling TSO can cause the dev_watchdog timer to be triggered because
> when TSO is disabled netif_tx_stop_all_queues is called.  If the watchdog
> timer fires while the queues are stopped and traffic has not recently been
> sent on a paticular queue this is falsly identified as a hang and
> ndo_tx_timeout() is called.  This is ocossionally seen during testing.
> 
> This removes the netif_tx_stop_all_queues() it is not needed.  The scheduler
> submits skb's with dev_hard_start_xmit(), this checks if netif_needs_gso and
> if so it calls dev_gso_segment.  Disabling TSO will cause dev_hard_start_xmit()
> to do the gso processing.   However ixgbe does not use the features flags to
> determine if it needs to use tso or not instead it uses skb->gso_size so
> ixgbe will process these frames correctly regardless of the netdev features
> flag.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
