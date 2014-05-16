From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCHv2 net-next] xen-netback: fix race between
 napi_complete() and interrupt handler
Date: Fri, 16 May 2014 09:30:09 +0100
Message-ID: <1400229009.883.37.camel@kazak.uk.xensource.com>
References: <1400174228-16572-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:60364 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755910AbaEPIac (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 04:30:32 -0400
In-Reply-To: <1400174228-16572-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-15 at 18:17 +0100, David Vrabel wrote:
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
> ---
> v2:
> - Rename xenvif_check_rx_xenvif() to
>   xenvif_napi_schedule_or_enable_irq() to make it more obvious what it
>   does.

Which is to update the event pointer such that IRQs are generated again
rather than enabling IRQs as such (enable_irq makes me think of
EFLAGS.IF). But given that I can't think of a better way to describe it:
Acked-by: Ian Campbell <ian.campbell@citrix.com>
(although in this area Wei's ack is more important than mine IMHO).

I think this is intended as a replacement to Wei's "xen-netback: don't
move event pointer in TX credit timeout callback" rather than in
addition to, correct?

Ian.
