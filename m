From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: Fix slot estimation
Date: Thu, 05 Jun 2014 15:02:09 -0700 (PDT)
Message-ID: <20140605.150209.365488173138758921.davem@davemloft.net>
References: <1401802336-25182-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, ian.campbell@citrix.com,
	wei.liu2@citrix.com, paul.durrant@citrix.com, linux@eikelenboom.it,
	netdev@vger.kernel.org, david.vrabel@citrix.com
To: zoltan.kiss@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013AbaFEWCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 18:02:11 -0400
In-Reply-To: <1401802336-25182-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Tue, 3 Jun 2014 14:32:16 +0100

> A recent commit (a02eb4 "xen-netback: worse-case estimate in xenvif_rx_action is
> underestimating") capped the slot estimation to MAX_SKB_FRAGS, but that triggers
> the next BUG_ON a few lines down, as the packet consumes more slots than
> estimated.
> This patch remove that cap, and if the frontend doesn't provide enough slot,
> put back the skb to the top of the queue and caps rx_last_skb_slots. When the
> next try also fails, it drops the packet.
> Capping rx_last_skb_slots is needed because if the frontend never gives enough
> slots, the ring gets stalled.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

Like David Laight, I do not like this patch at all.

Yes a crash or BUG_ON triggered is bad, but fixing it by deadlocking
TCP connections (a silent failure) is not an improvement.

I'm not applying this, sorry.
