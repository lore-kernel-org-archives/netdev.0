From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sky2: Fix crash inside sky2_rx_clean
Date: Wed, 26 Nov 2014 15:17:32 -0500 (EST)
Message-ID: <20141126.151732.832218547273018783.davem@davemloft.net>
References: <5475E012.3060607@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mlindner@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607AbaKZURe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 15:17:34 -0500
In-Reply-To: <5475E012.3060607@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mirko Lindner <mlindner@marvell.com>
Date: Wed, 26 Nov 2014 15:13:38 +0100

> If sky2->tx_le = pci_alloc_consistent() or sky2->tx_ring = kcalloc() in
> sky2_alloc_buffers() fails, sky2->rx_ring = kcalloc() will never be called.
> In this error case handling, sky2_rx_clean() is called from within
> sky2_free_buffers().
> 
> In sky2_rx_clean() we find the following:
> 
> ...
>    memset(sky2->rx_le, 0, RX_LE_BYTES);
> ...
> 
> This results in a memset using a NULL pointer and will crash the system.
> 
> Signed-off-by: Mirko Lindner <mlindner@marvell.com>

Applied, thanks.
