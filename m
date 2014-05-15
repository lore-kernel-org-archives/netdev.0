From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCHv2 net-next] xen-netback: fix race between napi_complete()
 and interrupt handler
Date: Thu, 15 May 2014 19:07:39 +0100
Message-ID: <20140515180739.GF10525@zion.uk.xensource.com>
References: <1400174228-16572-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:54066 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754959AbaEOSIB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 14:08:01 -0400
Content-Disposition: inline
In-Reply-To: <1400174228-16572-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014 at 06:17:08PM +0100, David Vrabel wrote:
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

Acked-by: Wei Liu <wei.liu2@citrix.com>
