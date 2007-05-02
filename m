From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 17/20][BNX2]: Enhance the heartbeat.
Date: Wed, 2 May 2007 09:40:13 +0100
Message-ID: <20070502084013.GB24804@infradead.org>
References: <1178068656.4820.53.camel@dell> <46383B00.4080605@garzik.org> <20070502.002426.38687430.davem@davemloft.net> <4638400D.5010306@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:35568 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654AbXEBIkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 04:40:33 -0400
Content-Disposition: inline
In-Reply-To: <4638400D.5010306@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 02, 2007 at 03:38:53AM -0400, Jeff Garzik wrote:
> David Miller wrote:
> >From: Jeff Garzik <jeff@garzik.org>
> >Date: Wed, 02 May 2007 03:17:20 -0400
> >
> >>Michael Chan wrote:
> >>>[BNX2]: Enhance the heartbeat.
> >>>
> >>>In addition to the periodic heartbeat, we're adding a heartbeat
> >>>request interrupt when the heartbeat is late.  This is useful
> >>>especially in -rt kernels where the timer frequently runs late.
> >>>
> >>>Signed-off-by: Michael Chan <mchan@broadcom.com>
> >>Should we really be adding code for such a special situation to upstream 
> >>code?
> >>
> >>I lean towards "no", but defer to your and DaveM's judgement here.
> >
> >My understanding of this situation is that if the timer is delayed a
> >lot, which can happen with the -rt kernel, we don't send the heartbeat
> >ping to the chip within the required margin.
> >
> >If the margin is not met, the ASF firmware takes this as a signal that
> >the host system is down, and does things like reset the network card
> >and other things we don't want it to do.
> 
> Thanks for the explanation.
> 
> My main concern was
> 
> * adding code to use a kernel facility
> * then, adding code to handle when that kernel facility doesn't work
> 
> and also
> 
> * adding code for a situation that never occurs in the upstream kernel.

Yeah, we shouldn't add this.  If the rt kernel can't deliver low latency
real time guarantees to the hardware it's pretty buggy :)
