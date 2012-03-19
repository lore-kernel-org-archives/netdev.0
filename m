From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/3] ixgbe: Fix issues with SR-IOV loopback when flow
 control is disabled
Date: Mon, 19 Mar 2012 17:38:01 -0400 (EDT)
Message-ID: <20120319.173801.655596594881567295.davem@davemloft.net>
References: <1331975254-19443-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39418 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755816Ab2CSViH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 17:38:07 -0400
In-Reply-To: <1331975254-19443-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 17 Mar 2012 02:07:34 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch allows us to avoid a Tx hang when SR-IOV is enabled.  This hang
> can be triggered by sending small packets at a rate that was triggering Rx
> missed errors from the adapter while the internal Tx switch and at least
> one VF are enabled.
> 
> This was all due to the fact that under heavy stress the Rx FIFO never
> drained below the flow control high water mark.  This resulted in the Tx
> FIFO being head of line blocked due to the fact that it relies on the flow
> control high water mark to determine when it is acceptable for the Tx to
> place a packet in the Rx FIFO.
> 
> The resolution for this is to set the FCRTH value to the RXPBSIZE - 32 so
> that even if the ring is almost completely full we can still place Tx
> packets on the Rx ring and drop incoming Rx traffic if we do not have
> sufficient space available in the Rx FIFO.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Sibai Li <sibai.li@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
