From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mv643xx_eth: reclaim TX skbs only when released
 by the HW
Date: Thu, 06 Nov 2014 14:55:34 -0500 (EST)
Message-ID: <20141106.145534.804171709065169233.davem@davemloft.net>
References: <1415197979-1702-1-git-send-email-karl.beldan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: karl.beldan@rivierawaves.com, netdev@vger.kernel.org,
	ijc@hellion.org.uk, eric.dumazet@gmail.com,
	ezequiel.garcia@free-electrons.com, sebastian.hesselbarth@gmail.com
To: karl.beldan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbaKFTzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:55:37 -0500
In-Reply-To: <1415197979-1702-1-git-send-email-karl.beldan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karl Beldan <karl.beldan@gmail.com>
Date: Wed,  5 Nov 2014 15:32:59 +0100

> From: Karl Beldan <karl.beldan@rivierawaves.com>
> 
> ATM, txq_reclaim will dequeue and free an skb for each tx desc released
> by the hw that has TX_LAST_DESC set. However, in case of TSO, each
> hw desc embedding the last part of a segment has TX_LAST_DESC set,
> losing the one-to-one 'last skb frag'/'TX_LAST_DESC set' correspondance,
> which causes data corruption.
> 
> Fix this by checking TX_ENABLE_INTERRUPT instead of TX_LAST_DESC, and
> warn when trying to dequeue from an empty txq (which can be symptomatic
> of releasing skbs prematurely).
> 
> Fixes: 3ae8f4e0b98 ('net: mv643xx_eth: Implement software TSO')
> Reported-by: Slawomir Gajzner <slawomir.gajzner@gmail.com>
> Reported-by: Julien D'Ascenzio <jdascenzio@yahoo.fr>
> Signed-off-by: Karl Beldan <karl.beldan@rivierawaves.com>

Applied and queued up for -stable, but it seems there might still be some
bugs to resolve...
