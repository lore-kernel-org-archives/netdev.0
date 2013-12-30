From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: fix guest-receive-side array sizes
Date: Sun, 29 Dec 2013 22:31:49 -0500 (EST)
Message-ID: <20131229.223149.1759825040763388964.davem@davemloft.net>
References: <1387790838-8852-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	ian.campbell@citrix.com, david.vrabel@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445Ab3L3Dbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 22:31:51 -0500
In-Reply-To: <1387790838-8852-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Mon, 23 Dec 2013 09:27:17 +0000

> The sizes chosen for the metadata and grant_copy_op arrays on the guest
> receive size are wrong;
> 
> - The meta array is needlessly twice the ring size, when we only ever
>   consume a single array element per RX ring slot
> - The grant_copy_op array is way too small. It's sized based on a bogus
>   assumption: that at most two copy ops will be used per ring slot. This
>   may have been true at some point in the past but it's clear from looking
>   at start_new_rx_buffer() that a new ring slot is only consumed if a frag
>   would overflow the current slot (plus some other conditions) so the actual
>   limit is MAX_SKB_FRAGS grant_copy_ops per ring slot.
> 
> This patch fixes those two sizing issues and, because grant_copy_ops grows
> so much, it pulls it out into a separate chunk of vmalloc()ed memory.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Acked-by: Wei Liu <wei.liu2@citrix.com>

Applied, thanks.
