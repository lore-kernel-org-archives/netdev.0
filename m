From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: Fix race condition on receive path.
Date: Fri, 5 Mar 2010 13:21:18 -0800
Message-ID: <20100305132118.1855617a@nehalam>
References: <1267817699.30393.8.camel@c-dwalke-linux.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jim Harford <c_jharfo@quicinc.com>, netdev@vger.kernel.org
To: Daniel Walker <dwalker@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37847 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754506Ab0CEVVu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Mar 2010 16:21:50 -0500
In-Reply-To: <1267817699.30393.8.camel@c-dwalke-linux.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 05 Mar 2010 11:34:59 -0800
Daniel Walker <dwalker@codeaurora.org> wrote:

> Fixes a race condition on the networking receive path that causes all
> received packets to be dropped after 15-60 minutes of heavy network usage.
> Function process_backlog() empties the receive queue, re-enables
> interrupts, then "completes" the softIRQ.  This provides a time window for
> netif_rx() to execute (in IRQ context) and enqueue a received packet
> without re-scheduling the softIRQ.  After this, the receive queue is never
> processed and the system eventually begins to drop all received packets.

I wonder why this hasn't shown up before?

Where exactly is the window between empty process_backlog and netif_rx?

Maybe it is ARM specific behavior of softirq?
