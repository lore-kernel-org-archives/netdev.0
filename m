From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sk_prot_alloc() should not blindly overwrite
 memory
Date: Sat, 11 Jul 2009 20:27:27 -0700 (PDT)
Message-ID: <20090711.202727.18146102.davem@davemloft.net>
References: <20090707.191424.167842005.davem@davemloft.net>
	<4A5441A0.3050504@gmail.com>
	<4A5581C5.5070409@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, emils.tantilov@gmail.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, jolsa@redhat.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37366
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752085AbZGLD1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2009 23:27:23 -0400
In-Reply-To: <4A5581C5.5070409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Jul 2009 07:36:05 +0200

> [PATCH] net: sk_prot_alloc() should not blindly overwrite memory
> 
> Some sockets use SLAB_DESTROY_BY_RCU, and our RCU code correctness
> depends on sk->sk_nulls_node.next being always valid. A NULL
> value is not allowed as it might fault a lockless reader.
> 
> Current sk_prot_alloc() implementation doesnt respect this hypothesis,
> calling kmem_cache_alloc() with __GFP_ZERO. Just call memset() around
> the forbidden field.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

APplied and queued up for -stable.
