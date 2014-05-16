From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCHv2 net-next] xen-netback: fix race between napi_complete()
 and interrupt handler
Date: Fri, 16 May 2014 09:39:46 +0100
Message-ID: <20140516083946.GA17887@zion.uk.xensource.com>
References: <1400174228-16572-1-git-send-email-david.vrabel@citrix.com>
 <1400229009.883.37.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Vrabel <david.vrabel@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>, Wei Liu <wei.liu2@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:20643 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932075AbaEPIjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 04:39:48 -0400
Content-Disposition: inline
In-Reply-To: <1400229009.883.37.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 09:30:09AM +0100, Ian Campbell wrote:
> On Thu, 2014-05-15 at 18:17 +0100, David Vrabel wrote:
> > When the NAPI budget was not all used, xenvif_poll() would call
> > napi_complete() /after/ enabling the interrupt.  This resulted in a
> > race between the napi_complete() and the napi_schedule() in the
> > interrupt handler.  The use of local_irq_save/restore() avoided by
> > race iff the handler is running on the same CPU but not if it was
> > running on a different CPU.
> > 
> > Fix this properly by calling napi_complete() before reenabling
> > interrupts (in the xenvif_napi_schedule_or_enable_irq() call).
> > 
> > Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> > ---
> > v2:
> > - Rename xenvif_check_rx_xenvif() to
> >   xenvif_napi_schedule_or_enable_irq() to make it more obvious what it
> >   does.
> 
> Which is to update the event pointer such that IRQs are generated again
> rather than enabling IRQs as such (enable_irq makes me think of
> EFLAGS.IF). But given that I can't think of a better way to describe it:
> Acked-by: Ian Campbell <ian.campbell@citrix.com>
> (although in this area Wei's ack is more important than mine IMHO).
> 
> I think this is intended as a replacement to Wei's "xen-netback: don't
> move event pointer in TX credit timeout callback" rather than in
> addition to, correct?
> 

That patch of mine is incorrect and it's not needed anymore.

Wei.

> Ian.
