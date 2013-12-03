From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net v2] xen-netback: clear vif->task on disconnect
Date: Tue, 3 Dec 2013 14:20:20 +0000
Message-ID: <20131203142020.GG14293@zion.uk.xensource.com>
References: <1386079585-3469-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:58484 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753085Ab3LCOUW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Dec 2013 09:20:22 -0500
Content-Disposition: inline
In-Reply-To: <1386079585-3469-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 03, 2013 at 02:06:25PM +0000, Paul Durrant wrote:
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
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

Thanks
Wei.
