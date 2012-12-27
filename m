From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] forcedeth: Fix WARNINGS that result when DMA mapping
 is not checked
Date: Thu, 27 Dec 2012 13:03:29 -0800
Message-ID: <1356642209.30414.1411.camel@edumazet-glaptop>
References: <1356637327-4884-1-git-send-email-Larry.Finger@lwfinger.net>
	 <1356638715.30414.1349.camel@edumazet-glaptop>
	 <50DCB1D9.50906@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:35886 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023Ab2L0VDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2012 16:03:32 -0500
In-Reply-To: <50DCB1D9.50906@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-27 at 14:38 -0600, Larry Finger wrote:
> On 12/27/2012 02:05 PM, Eric Dumazet wrote:
> > On Thu, 2012-12-27 at 13:42 -0600, Larry Finger wrote:

> >> +		if (pci_dma_mapping_error(np->pci_dev,
> >> +					  np->put_tx_ctx->dma))
> >> +			return NETDEV_TX_BUSY;
> >
> > Really this is not going to work very well : caller will call this in a
> > loop.
> 
> Any suggestions on what value should be returned, or does the caller need to be 
> modified?

NETDEV_TX_BUSY is really obsolete

Documentation/networking/driver.txt

In case of mapping error, I would drop the packet.

(kfree_skb() it, increment a device tx_dropped counter,  and return
NETDEV_TX_OK)
