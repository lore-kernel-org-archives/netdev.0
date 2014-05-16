From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net] xen-netback: fix race between napi_complete()
 and interrupt handler
Date: Fri, 16 May 2014 16:27:59 -0400 (EDT)
Message-ID: <20140516.162759.1966063113769346927.davem@davemloft.net>
References: <1400239202-10308-1-git-send-email-david.vrabel@citrix.com>
	<20140516112157.GI18551@zion.uk.xensource.com>
	<5375F5CC.6000000@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org, ian.campbell@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbaEPU2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 16:28:01 -0400
In-Reply-To: <5375F5CC.6000000@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Fri, 16 May 2014 12:26:04 +0100

> Dave, can you take this instead:
> 
> 8<--------------
> xen-netback: fix race between napi_complete() and interrupt handler
> 
> When the NAPI budget was not all used, xenvif_poll() would call
> napi_complete() /after/ enabling the interrupt.  This resulted in a
> race between the napi_complete() and the napi_schedule() in the
> interrupt handler.  The use of local_irq_save/restore() avoided by
> race iff the handler is running on the same CPU but not if it was
> running on a different CPU.
> 
> Fix this properly by calling napi_complete() before reenabling
> interrupts (in the xenvif_napi_schedule_or_enable_irq() call).
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Acked-by: Wei Liu <wei.liu2@citrix.com>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied, thanks everyone.
