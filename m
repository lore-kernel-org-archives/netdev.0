From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: Fix memory leak when discarding scattered
 packets
Date: Fri, 05 Jul 2013 01:29:58 -0700 (PDT)
Message-ID: <20130705.012958.510964485167451748.davem@davemloft.net>
References: <1372978126.1853.11.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755062Ab3GEIaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 04:30:01 -0400
In-Reply-To: <1372978126.1853.11.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 4 Jul 2013 23:48:46 +0100

> Commit 2768935a4660 ('sfc: reuse pages to avoid DMA mapping/unmapping
> costs') did not fully take account of DMA scattering which was
> introduced immediately before.  If a received packet is invalid and
> must be discarded, we only drop a reference to the first buffer's
> page, but we need to drop a reference for each buffer the packet
> used.
> 
> I think this bug was missed partly because efx_recycle_rx_buffers()
> was not renamed and so no longer does what its name says.  It does not
> change the state of buffers, but only prepares the underlying pages
> for recycling.  Rename it accordingly.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> This bug fix needs to go into 3.10.y as well.

Applied and queued up for -stable, thanks!
