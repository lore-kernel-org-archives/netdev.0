From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] xen-netback: clear vif->task on disconnect
Date: Tue, 03 Dec 2013 11:50:03 -0500 (EST)
Message-ID: <20131203.115003.2180347065954025261.davem@davemloft.net>
References: <1386079585-3469-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	wei.liu2@citrix.com, ian.campbell@citrix.com,
	david.vrabel@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036Ab3LCQuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 11:50:05 -0500
In-Reply-To: <1386079585-3469-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Tue, 3 Dec 2013 14:06:25 +0000

> xenvif_start_xmit() relies on checking vif->task for NULL to determine
> whether the vif is ready to accept packets. The task thread is stopped in
> xenvif_disconnect() but task is not set to NULL. Thus, on a re-connect the
> check will give a false positive.
> 
> Also since commit ea732dff5cfa10789007bf4a5b935388a0bb2a8f (Handle backend
> state transitions in a more robust way) it should not be possible for
> xenvif_connect() to be called if the vif is already connected so change the
> check of vif->tx_irq to a BUG_ON() and also add a BUG_ON(vif->task).
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>

Applied, thanks.
