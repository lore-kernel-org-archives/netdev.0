From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: fix starving rx ring when alloc_skb fails
Date: Fri, 17 Jun 2011 00:16:10 -0400 (EDT)
Message-ID: <20110617.001610.2160676566738613200.davem@davemloft.net>
References: <1308261747-17702-1-git-send-email-scottjg@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com
To: scottjg@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52021 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772Ab1FQEQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 00:16:12 -0400
In-Reply-To: <1308261747-17702-1-git-send-email-scottjg@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Scott J. Goldman" <scottjg@vmware.com>
Date: Thu, 16 Jun 2011 15:02:27 -0700

> if the rx ring is completely empty, then the device may never fire an rx
> interrupt. unfortunately, the rx interrupt is what triggers populating
> the rx ring with fresh buffers, so this will cause networking to lock
> up.
> 
> this patch recycles the last skb that we were about to indicate up to
> the network stack (only if the rx ring is completely starved of skbs)
> so the ring will never be completely empty. If we fail to allocate a
> secondary page buffer, we just indicate a 0 length buffer to the device.
> 
> Signed-off-by: Scott J. Goldman <scottjg@vmware.com>

This is why other drivers allocate the replacement skb _first_ before
handing the current receive packet to the stack.

And if the replacement allocation fails, they elide passing the packet
to the stack, and instead recycle it back onto the RX ring.

Please implement your RX policy in this manner, as we advise all Linux
networking drivers to, and you simply won't have this problem.
