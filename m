From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 1/6] r8169: check dma mapping failures
Date: Fri, 15 Oct 2010 16:11:07 +0200
Message-ID: <20101015141106.GB2291@redhat.com>
References: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
 <20101015134158.GA4417@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Denis Kirjanov <kirjanov@gmail.com>
To: Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17285 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754456Ab0JOOIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 10:08:47 -0400
Content-Disposition: inline
In-Reply-To: <20101015134158.GA4417@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 15, 2010 at 03:41:58PM +0200, Francois Romieu wrote:
> Stanislaw Gruszka <sgruszka@redhat.com> :
> > Check possible dma mapping errors and do clean up if it happens,
> > when sending frames stop the tx queue.
> 
> Almost ok: NETDEV_TX_BUSY can not be used like that. Afaik the DMA
> failure path in the driver really wants a NETDEV_TX_OK (and a device
> stats update, though missing in tg3 ?).

I'm not sure if any driver handle that in the right way. Returning
"TX OK" when the transmission was not "OK", doesn't look correctly
to me.

Eric, David, what you think?

> Actually the former NETDEV_TX_BUSY condition mostly checks for a bug.

Driver handling code from net/core/*.c does not give me such impression.

Stanislaw
