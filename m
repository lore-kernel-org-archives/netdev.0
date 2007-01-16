From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IrDA] irda-usb TX path optimization
Date: Mon, 15 Jan 2007 19:37:54 -0800 (PST)
Message-ID: <20070115.193754.59662700.davem@davemloft.net>
References: <20070110.152607.125896247.davem@davemloft.net>
	<20070111120154.GA4175@sortiz.org>
	<20070115091511.GA3532@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avl@logic.at, netdev@vger.kernel.org,
	irda-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55763
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932151AbXAPDhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 22:37:54 -0500
To: samuel@sortiz.org
In-Reply-To: <20070115091511.GA3532@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Mon, 15 Jan 2007 11:15:11 +0200

> Since we stop using dev_alloc_skb on the IrDA TX frame, we constantly run
> into the case of the skb headroom being 0, and thus we call skb_cow for
> every IrDA TX frame.
> This patch uses a local buffer and memcpy the skb to it, saving us a
> kmalloc for each of those IrDA TX frames.
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied, thanks.

Technically this is a bug fix too because once an SKB hits the
transmit function it should essentially be immutable, ie. you
shouldn't be writing to it.  tcpdump sniffers could be looking
at the SKB, as one example.
