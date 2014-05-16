From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCHv3 net] xen-netback: fix race between napi_complete() and
 interrupt handler
Date: Fri, 16 May 2014 12:21:57 +0100
Message-ID: <20140516112157.GI18551@zion.uk.xensource.com>
References: <1400239202-10308-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:61753 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756561AbaEPLV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 07:21:58 -0400
Content-Disposition: inline
In-Reply-To: <1400239202-10308-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 12:20:02PM +0100, David Vrabel wrote:
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
> Acked-by: Wei Lui <wei.lui2@citrix.com>

It's "Liu". ;-)
