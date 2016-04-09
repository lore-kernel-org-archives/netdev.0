From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Lsf] [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Sat, 09 Apr 2016 05:34:38 -0700
Message-ID: <1460205278.6473.486.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	 <20160407161715.52635cac@redhat.com>
	 <1460042309.6473.414.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160409111132.781a11b6@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Tom Herbert
 <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>,
 lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 lsf-pc@lists.linux-foundation.org, Alexei Starovoitov
 <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160409111132.781a11b6@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-04-09 at 11:11 +0200, Jesper Dangaard Brouer wrote:
> Hi Eric,


> Above code is okay.  But do you think we also can get away with the same
> trick we do with the SKB refcnf?  Where we avoid an atomic operation if
> refcnt==1.
> 
> void kfree_skb(struct sk_buff *skb)
> {
> 	if (unlikely(!skb))
> 		return;
> 	if (likely(atomic_read(&skb->users) == 1))
> 		smp_rmb();
> 	else if (likely(!atomic_dec_and_test(&skb->users)))
> 		return;
> 	trace_kfree_skb(skb, __builtin_return_address(0));
> 	__kfree_skb(skb);
> }
> EXPORT_SYMBOL(kfree_skb);

No we can not use this trick this for pages :

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ec91698360b3818ff426488a1529811f7a7ab87f






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
