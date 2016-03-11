From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvtap: always pass ethernet header in linear
Date: Fri, 11 Mar 2016 14:45:54 -0500 (EST)
Message-ID: <20160311.144554.1233700363485262783.davem@davemloft.net>
References: <1457468334-66777-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932127AbcCKTp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 14:45:56 -0500
In-Reply-To: <1457468334-66777-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Tue,  8 Mar 2016 15:18:54 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> The stack expects link layer headers in the skb linear section.
> Macvtap can create skbs with llheader in frags in edge cases:
> when (IFF_VNET_HDR is off or vnet_hdr.hdr_len < ETH_HLEN) and
> prepad + len > PAGE_SIZE and vnet_hdr.flags has no or bad csum.
> 
> Add checks to ensure linear is always at least ETH_HLEN.
> At this point, len is already ensured to be >= ETH_HLEN.
> 
> For backwards compatiblity, rounds up short vnet_hdr.hdr_len.
> This differs from tap and packet, which return an error.
> 
> Fixes b9fb9ee07e67 ("macvtap: add GSO/csum offload support")
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied to net-next and queued up for -stable, thanks.
