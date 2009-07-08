From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sk_prot_alloc() should not blindly overwrite
 memory
Date: Tue, 07 Jul 2009 19:14:24 -0700 (PDT)
Message-ID: <20090707.191424.167842005.davem@davemloft.net>
References: <4A537469.3040207@gmail.com>
	<EA929A9653AAE14F841771FB1DE5A1365F8ACEBEE9@rrsmsx501.amr.corp.intel.com>
	<4A53CD39.7080407@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, emils.tantilov@gmail.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, jolsa@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33083
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756942AbZGHCOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 22:14:22 -0400
In-Reply-To: <4A53CD39.7080407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Jul 2009 00:33:29 +0200

> [PATCH] net: sk_prot_alloc() should not blindly overwrite memory
> 
> Some sockets use SLAB_DESTROY_BY_RCU, and our RCU code rely that some
> fields should not be blindly overwritten, even with null.
> 
> These fields are sk->sk_refcnt and sk->sk_nulls_node.next
> 
> Current sk_prot_alloc() implementation doesnt respect this hypothesis,
> calling kmem_cache_alloc() with __GFP_ZERO and setting sk_refcnt to 1
> instead of atomically increment it.
> 
> Reported-by: Emil S Tantilov <emils.tantilov@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I've applied this but will wait for some more testing before
I push it out for real to kernel.org
