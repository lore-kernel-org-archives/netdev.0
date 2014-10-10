From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Fri, 10 Oct 2014 15:34:21 -0400 (EDT)
Message-ID: <20141010.153421.869334149742394721.davem@davemloft.net>
References: <20141010190716.8311.98709.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbaJJTeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 15:34:23 -0400
In-Reply-To: <20141010190716.8311.98709.stgit@ahduyck-workstation.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: alexander.duyck@gmail.com
Date: Fri, 10 Oct 2014 12:09:12 -0700

> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> 
> This patch addresses a kernel unaligned access bug seen on a sparc64 system
> with an igb adapter.  Specifically the __skb_flow_get_ports was returning a
> be32 pointer which was then having the value directly returned.
> 
> In order to prevent this it is actually easier to simply not populate the
> ports or address values when an skb is not present.  In this case the
> assumption is that the data isn't needed and rather than slow down the
> faster aligned accesses by making them have to assume the unaligned path on
> architectures that don't support efficent unaligned access it makes more
> sense to simply switch off the bits that were copying the source and
> destination address/port for the case where we only care about the protocol
> types and lengths which are normally 16 bit fields anyway.
> 
> Reported-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
> 
> v2: Fixed alignment to __be16 on ports
> v3: Discarded previous approach and instead simplified things by
>     not populating ports, or src/dst addresses if skb is not present.
>     By doing this we avoid the unaligned access issue entirely and do not
>     populate fields that will not be used by the eth_get_headlen function.
> v4: Minor whitespace cleanups
>     Added workaround for access of doff resulting in unaligned access

Applied, thanks Alex.
