From: Joe Perches <joe@perches.com>
Subject: Re: [Patch v1] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Sun, 26 May 2013 15:00:07 -0700
Message-ID: <1369605607.2034.4.camel@joe-AO722>
References: <1369574241-21397-1-git-send-email-atomlin@redhat.com>
	 <51A23825.7000303@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: atomlin@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
	edumazet@google.com, pshelar@nicira.com, mst@redhat.com,
	alexander.h.duyck@intel.com, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51A23825.7000303@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-05-26 at 20:28 +0400, Sergei Shtylyov wrote:
> On 26-05-2013 17:17, atomlin@redhat.com wrote:
> > Failed GFP_ATOMIC allocations by the network stack result in dropped
> > packets, which will be received on a subsequent retransmit, and an
> > unnecessary, noisy warning with a kernel backtrace.
> 
> > These warnings are harmless, but they still cause users to panic and
> > file bug reports over dropped packets. It would be better to hide the
> > failed allocation warnings and backtraces, and let retransmits handle
> > dropped packets quietly.

> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
[]
> > @@ -236,7 +236,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
> >   		? skbuff_fclone_cache : skbuff_head_cache;
> >
> >   	if (sk_memalloc_socks() && (flags & SKB_ALLOC_RX))
> > -		gfp_mask |= __GFP_MEMALLOC;
> > +		gfp_mask |= (__GFP_MEMALLOC|__GFP_NOWARN);
> 
>     Parens not needed here.

Maybe add a pr_debug before the goto out instead.
