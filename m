From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] xen-netback: count number required slots for an
 skb more carefully
Date: Thu, 12 Sep 2013 23:23:28 -0400 (EDT)
Message-ID: <20130912.232328.1199260755421139102.davem@davemloft.net>
References: <1378907568-8062-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, konrad.wilk@oracle.com,
	boris.ostrovsky@oracle.com, netdev@vger.kernel.org,
	ian.campbell@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418Ab3IMDX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 23:23:29 -0400
In-Reply-To: <1378907568-8062-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Wed, 11 Sep 2013 14:52:48 +0100

> From: David Vrabel <david.vrabel@citrix.com>
> 
> When a VM is providing an iSCSI target and the LUN is used by the
> backend domain, the generated skbs for direct I/O writes to the disk
> have large, multi-page skb->data but no frags.
> 
> With some lengths and starting offsets, xen_netbk_count_skb_slots()
> would be one short because the simple calculation of
> DIV_ROUND_UP(skb_headlen(), PAGE_SIZE) was not accounting for the
> decisions made by start_new_rx_buffer() which does not guarantee
> responses are fully packed.
 ...
> Fix this by counting the number of required slots more carefully.  In
> xen_netbk_count_skb_slots(), more closely follow the algorithm used by
> xen_netbk_gop_skb() by introducing xen_netbk_count_frag_slots() which
> is the dry-run equivalent of netbk_gop_frag_copy().
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>
> --
> v2: xen_netbk_* -> xenvif_* to match new style

Thanks for resolving this into a final patch after so much back and
forth :-)

I assume you want this queued up for -stable, and can you check if
there is any non-trivial backporting for earlier kernels?
