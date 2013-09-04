From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] gianfar: Fix reported number of sent bytes
 to BQL
Date: Tue, 03 Sep 2013 22:14:48 -0400 (EDT)
Message-ID: <20130903.221448.1127418200981735343.davem@davemloft.net>
References: <1367251193.8964.326.camel@edumazet-glaptop>
	<1377864075-19491-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814Ab3IDCOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 22:14:49 -0400
In-Reply-To: <1377864075-19491-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Fri, 30 Aug 2013 15:01:15 +0300

> Fix the amount of sent bytes reported to BQL by reporting the
> number of bytes on wire in the xmit routine, and recording that
> value for each skb in order to be correctly confirmed on Tx
> confirmation cleanup.
> 
> Reporting skb->len to BQL just before exiting xmit is not correct
> due to possible insertions of TOE block and alignment bytes in the
> skb->data, which are being stripped off by the controller before
> transmission on wire.  This led to mismatch of (incorrectly)
> reported bytes to BQL b/w xmit and Tx confirmation, resulting in
> Tx timeout firing, for the h/w tx timestamping acceleration case.
> 
> There's no easy way to obtain the number of bytes on wire in the Tx
> confirmation routine, so skb->cb is used to convey that information
> from xmit to Tx confirmation, for now (as proposed by Eric). Revived
> the currently unused GFAR_CB() construct for that purpose.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied.
