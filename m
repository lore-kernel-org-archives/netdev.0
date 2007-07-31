From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH]: Fix sk_buff page offsets and lengths.
Date: Tue, 31 Jul 2007 10:52:15 +0200
Message-ID: <20070731105215.b7e1044c.dada1@cosmosbay.com>
References: <20070730.185028.26532012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au,
	shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:53297 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759013AbXHAOkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 10:40:05 -0400
In-Reply-To: <20070730.185028.26532012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Jul 2007 18:50:28 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> Stephen Rothwell pointed out to me that the skb_frag_struct
> is broken on platforms using 64K or larger page sizes, it
> even generates warnings when (for example) the myri10ge driver
> tries to assign PAGE_SIZE into frag->size.
> 
> I've thus increased page offset and size to __u32 in the patch below.
> 
> I made this change much to even my own chagrin, but this is the
> most direct fix and the ifdefs we could put here are both ugly
> and also not something that we do with struct scatterlist so
> no reason to do it in a place like this.
> 
> Actually, the cost on 64-bit is zero because there existed 4 bytes of
> alignment padding for skb_frag_struct because of the page pointer.
> On 32-bit the cost is up to 64-bytes :-/
> 
> Stephen, this opens up the doors a bit for the scatterlist work
> you wanted to do in sk_buff.
> 

Ouch... 

sizeof(struct skb_shared_info) is enlarged by 18*4 bytes on i386, a litle bit more than 64 bytes :(

I understand ifdefs are ugly, but in the common case (PAGE_SIZE<64K), this change seems very unfortunate.

