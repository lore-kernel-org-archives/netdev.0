From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Don't warn if high-order hash resize fails
Date: Sun, 13 May 2007 23:36:35 -0700 (PDT)
Message-ID: <20070513.233635.28398106.davem@davemloft.net>
References: <20070514054837.GA18879@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58047
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752100AbXENGgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 02:36:45 -0400
In-Reply-To: <20070514054837.GA18879@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 14 May 2007 15:48:37 +1000

> Hi Dave:
> 
> I just got this when rekeying my VPN (2.6.21.1):
> 
> events/0: page allocation failure. order:7, mode:0xd0
>  [<c0146235>] __alloc_pages+0x1e5/0x2e0
>  [<c0146356>] __get_free_pages+0x26/0x50
>  [<c02a01ef>] xfrm_hash_alloc+0x2f/0x80
>  [<c029a947>] xfrm_bydst_resize+0x37/0xc0
>  [<c029aa70>] xfrm_hash_resize+0x0/0x80
>  [<c029aae7>] xfrm_hash_resize+0x77/0x80
>  [<c012a8ea>] run_workqueue+0x8a/0x190
>  [<c012ab17>] worker_thread+0x127/0x160
>  [<c0117490>] default_wake_function+0x0/0x10
>  [<c01174d7>] __wake_up_common+0x37/0x70
>  [<c0117490>] default_wake_function+0x0/0x10
>  [<c012a9f0>] worker_thread+0x0/0x160
>  [<c012e044>] kthread+0xb4/0xc0
>  [<c012df90>] kthread+0x0/0xc0
>  [<c0105287>] kernel_thread_helper+0x7/0x10
>  =======================
> 
> Isn't an order-7 allocation (half a meg) a bit over-the-top for that hash,
> especially since I've got a grand total of 4 SAs :)
> 
> Anyway, we shouldn't warn about these allocations since they're expected
> to fail after the box has been up for a while.  Also, should we try
> vmalloc when it does fail?

Thanks I'll add the warning fix, but there must be some counter
bug if it tried to grow to order-7, that really shouldn't
be happening.
