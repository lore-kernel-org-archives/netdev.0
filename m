From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during
	MTU change
Date: Tue, 3 Jun 2008 23:51:55 +0200
Message-ID: <20080603215155.GA9712@electric-eye.fr.zoreil.com>
References: <20080531184615.350bac00@infradead.org> <20080603134019.df2f51d4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>, alan@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35759 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753158AbYFCWTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 18:19:09 -0400
Content-Disposition: inline
In-Reply-To: <20080603134019.df2f51d4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> :
[...]
> So hrm.  It could all be a lot better.  Just looking quickly at the
> code I _think_ we might be able to do all the needed allocations
> outside the lock and then swizzle them into place after taking the
> lock. ie, something as simple as:
[...]
> 	velocity_init_rd_ring(temp_vptr);	/* Can use GFP_KERNEL! */
> 
> 	spin_lock_irqsave(&vptr->lock, flags);
> 
> 	velocity_free_td_ring(vptr);
> 	velocity_free_rd_ring(vptr);
> 
> 	vptr->foo = temp_vptr->foo;
> 	vptr->bar = temp_vptr->bar;
> 	...
> 
> 	spin_unlock_irqrestore(&vptr->lock, flags);
> 
> ?

Almost.

I'll wrap it in the next 24 hours.

-- 
Ueimor
