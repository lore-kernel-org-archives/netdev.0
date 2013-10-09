From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] net: sh_eth: Fix RX packets errors on R8A7740
Date: Wed, 9 Oct 2013 14:26:17 +0900
Message-ID: <20131009052617.GC16885@verge.net.au>
References: <1381127365-6521-1-git-send-email-nh-ky@jinso.co.jp>
 <1381127365-6521-2-git-send-email-nh-ky@jinso.co.jp>
 <20131009042826.GB16885@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ryusuke Sakato <ryusuke.sakato.bx@renesas.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Nguyen Hong Ky <nh-ky@jinso.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:50044 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051Ab3JIF0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 01:26:21 -0400
Content-Disposition: inline
In-Reply-To: <20131009042826.GB16885@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 09, 2013 at 01:28:26PM +0900, Simon Horman wrote:
> On Mon, Oct 07, 2013 at 03:29:25PM +0900, Nguyen Hong Ky wrote:
> > This patch will fix RX packets errors when receiving big size
> > of data by set bit RNC = 1.
> > 
> > RNC - Receive Enable Control
> > 
> > 0: Upon completion of reception of one frame, the E-DMAC writes
> > the receive status to the descriptor and clears the RR bit in
> > EDRRR to 0.
> > 
> > 1: Upon completion of reception of one frame, the E-DMAC writes
> > (writes back) the receive status to the descriptor. In addition,
> > the E-DMAC reads the next descriptor and prepares for reception
> > of the next frame.
> > 
> > In addition, for get more stable when receiving packets, I set
> > maximum size for the transmit/receive FIFO and inserts padding
> > in receive data.
> > 
> > Signed-off-by: Nguyen Hong Ky <nh-ky@jinso.co.jp>
> 
> I realise that this patch has been applied but regardless
> I would like to acknowledge that it resolve a problem that
> I observed this afternoon.
> 
> Without this patch I see the following on the console, many times:
> 
> net eth0: Receive FIFO Overflow
> 
> With this patch I do not see the warning message at all.

Scratch that, I am still seeing the messages with this patch applied.
