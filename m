From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Mon, 11 Apr 2016 22:23:09 +0200
Message-ID: <20160411222309.499a2125@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<1460042309.6473.414.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160409111132.781a11b6@redhat.com>
	<1460205278.6473.486.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lsf@lists.linux-foundation.org, Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        James Bottomley
 <James.Bottomley@HansenPartnership.com>,
        linux-mm <linux-mm@kvack.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        lsf-pc@lists.linux-foundation.org,
        Alexei Starovoitov
 <alexei.starovoitov@gmail.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1460205278.6473.486.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


On Sat, 09 Apr 2016 05:34:38 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Sat, 2016-04-09 at 11:11 +0200, Jesper Dangaard Brouer wrote:
> 
> > Above code is okay.  But do you think we also can get away with the same
> > trick we do with the SKB refcnf?  Where we avoid an atomic operation if
> > refcnt==1.
> > 
> > void kfree_skb(struct sk_buff *skb)
> > {
> > 	if (unlikely(!skb))
> > 		return;
> > 	if (likely(atomic_read(&skb->users) == 1))
> > 		smp_rmb();
> > 	else if (likely(!atomic_dec_and_test(&skb->users)))
> > 		return;
> > 	trace_kfree_skb(skb, __builtin_return_address(0));
> > 	__kfree_skb(skb);
> > }
> > EXPORT_SYMBOL(kfree_skb);  
> 
> No we can not use this trick this for pages :
> 
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ec91698360b3818ff426488a1529811f7a7ab87f
> 

If we have a page-pool recycle facility, then we could use the trick,
right? (As we know that get_page_unless_zero() cannot happen for pages
in the pool).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
