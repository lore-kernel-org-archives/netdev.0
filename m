From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] net: consolidate netif_needs_gso() checks
Date: Mon, 21 Jun 2010 13:55:09 -0700 (PDT)
Message-ID: <20100621.135509.260072870.davem@davemloft.net>
References: <20100617001804.5155.30862.stgit@localhost.localdomain>
	<20100617101857.GA1053@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, john.r.fastabend@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50863
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758466Ab0FUUy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 16:54:57 -0400
In-Reply-To: <20100617101857.GA1053@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 17 Jun 2010 20:18:57 +1000

> On Wed, Jun 16, 2010 at 05:18:12PM -0700, Jeff Kirsher wrote:
>> From: John Fastabend <john.r.fastabend@intel.com>
>> 
>> netif_needs_gso() is checked twice in the TX path once,
>> before submitting the skb to the qdisc and once after
>> it is dequeued from the qdisc just before calling
>> ndo_hard_start().  This opens a window for a user to
>> change the gso/tso or tx checksum settings that can
>> cause netif_needs_gso to be true in one check and false
>> in the other.
>> 
>> Specifically, changing TX checksum setting may cause
>> the warning in skb_gso_segment() to be triggered if
>> the checksum is calculated earlier.
>> 
>> This consolidates the netif_needs_gso() calls so that
>> the stack only checks if gso is needed in
>> dev_hard_start_xmit().
>> 
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> Cc: Herbert Xu <herbert@gondor.apana.org.au>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
