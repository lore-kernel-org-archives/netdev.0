From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 3/3] gianfar: Implement PAUSE frame
 generation support
Date: Wed, 29 Oct 2014 14:34:18 -0400 (EDT)
Message-ID: <20141029.143418.274385566081130545.davem@davemloft.net>
References: <1414399364-22308-1-git-send-email-matei.pavaluca@freescale.com>
	<1414399364-22308-3-git-send-email-matei.pavaluca@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com
To: matei.pavaluca@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755398AbaJ2SeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 14:34:20 -0400
In-Reply-To: <1414399364-22308-3-git-send-email-matei.pavaluca@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matei Pavaluca <matei.pavaluca@freescale.com>
Date: Mon, 27 Oct 2014 10:42:44 +0200

> The hardware can automatically generate pause frames when the number
> of free buffers drops under a certain threshold, but in order to do this,
> the address of the last free buffer needs to be written to a specific
> register for each RX queue.
> 
> This has to be done in 'gfar_clean_rx_ring' which is called for each
> RX queue. In order not to impact performance, by adding a register write
> for each incoming packet, this operation is done only when the PAUSE frame
> transmission is enabled.
> 
> Whenever the link is readjusted, this capability is turned on or off.
> 
> Signed-off-by: Matei Pavaluca <matei.pavaluca@freescale.com>

Applied.

But I would turn pause frames on by default, and deal with the
"performance" issue by aggregating the register writes.  Only
do it every N cleaned frames.
