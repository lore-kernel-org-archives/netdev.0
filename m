From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Tue, 8 Aug 2006 13:04:32 -0400
Message-ID: <20060808170432.GD27383@kvack.org>
References: <20060804101017.GA17393@gondor.apana.org.au> <1154712532.3117.43.camel@rh4> <20060804110829.62136ebb@dxpl.pdx.osdl.net> <20060804.163111.85390037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, mchan@broadcom.com,
	herbert@gondor.apana.org.au, hadi@cyberus.ca,
	jesse.brandeburg@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:10671 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S1030196AbWHHRJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 13:09:14 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060804.163111.85390037.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 04, 2006 at 04:31:11PM -0700, David Miller wrote:
> Yes, it's meant to catch unintented races.
> 
> The queueing layer that calls ->hard_start_xmit() technically has no
> need to support NETDEV_TX_BUSY as a return value, since the device
> is able to prevent this.
> 
> If we could avoid NETDEV_TX_BUSY et al. from happening, the idea is
> that we could eliminate all of the requeueing logic in the packet
> scheduler layer.  It is a pipe dream from many years ago.

Maybe the way NETDEV_TX_BUSY is implemented is wrong -- that is, it should 
be possible to return a result saying "we sent the packet, but the queue is 
now full".  That would eliminate the atomic op that netif_queue_stop() 
performs and allow higher layers to merge the necessary barrier on the full 
case with the op on the tx lock.  That way we could have lockless queue 
handling within the driver.  This might need start/stop sequence counters, 
though.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
