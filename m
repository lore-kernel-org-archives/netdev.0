From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH v2 0/4] Defer skb allocation for both mergeable buffers
 and big packets in virtio_net
Date: Mon, 14 Dec 2009 11:59:57 -0800
Message-ID: <1260820797.8716.2.camel@localhost.localdomain>
References: <1258697359.7416.14.camel@localhost.localdomain>
	 <200911231123.18898.rusty@rustcorp.com.au>
	 <20091208122134.GA17286@redhat.com>
	 <1260534506.30371.6.camel@localhost.localdomain>
	 <20091213101907.GA6789@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758175AbZLNUAK@vger.kernel.org>
In-Reply-To: <20091213101907.GA6789@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2009-12-13 at 12:19 +0200, Michael S. Tsirkin wrote:
> 
> Shirley, some advice on packaging patches
> that I hope will be helpful:
> 
> You did try to split up the patch logically,
> and it's better than a single huge patch, but it
> can be better.  For example, you add static functions
> in one patch and use them in another patch,
> this works well for new APIs which are documented
> so you can understand from the documentation
> what function should do, but not for internal, static functions:
> one ends up looking at usage, going back to implementation,
> back to usage, each time switching between patches.
> 
> One idea on how to split up the patch set better:
> - add new "destroy" API and supply documentation
> - switch current implementation over to use destroy API
> - split current implementation into subfunctions
>   handling mergeable/big cases
> - convert functions to use deferred allocation
>   [would be nice to convert mergeable/big separately,
>    but I am not sure this is possible while keeping
>    patchset bisectable]
> 
> Some suggestions on formatting:
> - keep patch names short, and prefix with module name,
>   not patchset name, so that git summaries look nicer. E.g.
>   Defer skb allocation -- add destroy buffers function for virtio
>   Would be better "virtio: add destroy buffers function".
> - please supply commit message with some explanation
>   and motivation that will help someone looking
>   at git history, without background from mailing list.
>   E.g.
>   "Add "destroy" vq API that returns all posted
>    buffers back to caller. This makes it possible
>    to avoid tracking buffers in callers to free
>    them on vq teardown. Will be used by deferred
>    skb allocation patch.".
> - Use "---" to separate description from text,
>   and generally make patch acceptable to git am.
>   It is a good idea to use git to generate patches,
>   for example with git format-patch.
>   I usually use it with --numbered --thread --cover-letter.
> 
> > Guest virtio_net receives packets from its pre-allocated vring 
> > buffers, then it delivers these packets to upper layer protocols
> > as skb buffs. So it's not necessary to pre-allocate skb for each
> > mergable buffer, then frees it when it's useless. 
> > This patch has deferred skb allocation when receiving packets for
> > both big packets and mergeable buffers. It reduces skb
> pre-allocations 
> > and skb_frees.
> 
> E.g. the above should go into commit message for the virtio net
> part of patchset.

Nice comments, will include them.


> I think you need to base your patch on Dave's net-next,
> it's too late to put it in 2.6.32, or even 2.6.33.
> It also should probably go in through Dave's tree because virtio part
> of
> patch is very small, while most of it deals with net/virtio_net.

> > Tests have been done for small packets, big packets
> > and mergeable buffers.
> > 
> > The single netperf TCP_STREAM performance improved for host to
> guest. 
> > It also reduces UDP packets drop rate.
> 
> 
> BTW, any numbers?  Also, 2.6.32 has regressed as compared to 2.6.31.
> Did you try with Sridhar Samudrala's patch from net-next applied
> that reportedly fixes this?

Ok, I will run Dave's net-next tree.

Thanks
Shirley
