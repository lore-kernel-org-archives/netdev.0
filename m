From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: fix starving rx ring when alloc_skb fails
Date: Fri, 17 Jun 2011 00:53:56 -0400 (EDT)
Message-ID: <20110617.005356.180809929241094878.davem@davemloft.net>
References: <1308261747-17702-1-git-send-email-scottjg@vmware.com>
	<20110617.001610.2160676566738613200.davem@davemloft.net>
	<03E840D17E263A48A5766AD576E0423A012911782E@exch-mbx-111.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com
To: scottjg@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754186Ab1FQEyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 00:54:00 -0400
In-Reply-To: <03E840D17E263A48A5766AD576E0423A012911782E@exch-mbx-111.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Goldman <scottjg@vmware.com>
Date: Thu, 16 Jun 2011 21:40:15 -0700

> I'm sorry if my patch description was unclear, but as I understand it, what you are describing is what this patch implements. The patched rx handler does something like:
> 1) poll the rx ring, peel off a pending skb (don't pass the packet up the stack yet)
> 2) if the ring needs to be repopulated, we do that
> 3) if the ring was repopulated successfully, then that's great, and we pass up the pending skb to the network stack.
> 4) if not and there are no skbs left on the ring, we reuse the pending skb and recycle it back on the ring (effectively dropping the packet we were about to pass up to the network stack)

You shouldn't restrict this logic to when the ring is empty, you
should never leave any RX ring slots empty.

Every RX ring entry should be processed with a "alloc_skb()" first,
and if the allocation fails you recycle the RX ring's SKB.
