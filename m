From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Fri, 4 Feb 2005 01:27:05 +1100
Message-ID: <20050203142705.GA11318@krispykreme.ozlabs.ibm.com>
References: <20050131102920.GC4170@suse.de> <E1CvZo6-0001Bz-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf Kirch <okir@suse.de>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1CvZo6-0001Bz-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
Hi,

> For example, in this particular case, a more sinister (but probably
> impossible for sk_buff objects) problem would be for the list removal
> itself to be delayed until after the the kfree_skb.  This could
> potentially mean that we're reading/writing memory that's already
> been freed.
> 
> Perhaps we should always add a barrier to such operations.  So
> kfree_skb would become
> 
> 	if (atomic_read(&skb->users) != 1) {
> 		smp_mb__before_atomic_dec();
> 		if (!atomic_dec_and_test(&skb->users))
> 			return;
> 	}
> 	__kfree_skb(skb);

Architectures should guarantee that any of the atomics and bitops that
return values order in both directions. So you dont need the
smp_mb__before_atomic_dec here.

It is, however, required on the atomics and bitops that dont return
values. Its difficult stuff, everyone gets it wrong and Andrew keeps
hassling me to write up a document explaining it.

Anton
