From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/core: Handle csum for CHECKSUM_COMPLETE VXLAN
 forwarding
Date: Mon, 22 Dec 2014 16:21:43 -0500 (EST)
Message-ID: <20141222.162143.1589102649309575725.davem@davemloft.net>
References: <2983.1419031920@famine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jay.vosburgh@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754869AbaLVVVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 16:21:46 -0500
In-Reply-To: <2983.1419031920@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <jay.vosburgh@canonical.com>
Date: Fri, 19 Dec 2014 15:32:00 -0800

> 	The receive code is careful to update the skb->csum, except in
> __dev_forward_skb, as called by dev_forward_skb.  __dev_forward_skb
> calls eth_type_trans, which in turn calls skb_pull_inline(skb, ETH_HLEN)
> to skip over the Ethernet header, but does not update skb->csum when
> doing so.

Hmmm, wasn't there some discussion about doing the skb_postpull_rcsum()
in eth_type_trans()?

But I guess that won't work for non-encapsulated ethernet cases?
