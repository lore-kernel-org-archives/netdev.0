From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] mlx4_en: moderate frequency of TX
 completions
Date: Thu, 23 Feb 2012 14:44:37 -0500 (EST)
Message-ID: <20120223.144437.32389814881687535.davem@davemloft.net>
References: <4F464063.1010001@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756500Ab2BWToo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 14:44:44 -0500
In-Reply-To: <4F464063.1010001@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 23 Feb 2012 15:34:27 +0200

> No need to ask for completion for every packet being sent.
> So the method is to ask for a completion every 16 packets,
> or when the queue is about to be full.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

You absolutely cannot do this, you must signal completion and free up
TX queue packets in a finite amount of time.

This means that if you suddenly stop getting new packets to send
you must still free up all the pending TX SKBs even if no more
packets are given to the driver.

Does your hardware unconditionally give a TX completion interrupt when
the TX queue empties completely?  If not, then you cannot make the
change contained in this patch.
