From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Wed, 02 Sep 2015 14:30:45 -0700
Message-ID: <1441229445.8932.206.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
	 <1441133703-1570969-4-git-send-email-kafai@fb.com>
	 <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150902205802.GA78846@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36186 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756007AbbIBVar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 17:30:47 -0400
Received: by pacwi10 with SMTP id wi10so23302668pac.3
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 14:30:47 -0700 (PDT)
In-Reply-To: <20150902205802.GA78846@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-02 at 13:58 -0700, Martin KaFai Lau wrote:
> On Tue, Sep 01, 2015 at 01:14:20PM -0700, Eric Dumazet wrote:
> > > 2. Use a spinlock to protect the dst_cache operations
> >
> > Well, a seqlock would be better : No need for an atomic operation in
> > fast path.
> >
> seqlock can ensure consistency between idst->dst and idst->cookie.
> However, IPv6 dst destruction is not protected by rcu.  dst_free() is
> directly called, like in ip6_fib.c and a few other places.
> Hence, atomic_inc_not_zero() cannot be used here because the dst may
> have already been kmem_cache_free() when refcnt is 0.

Really ? What about basic rcu rules ?

Object cannot be freed until all cpus have exited their RCU sections.

>   A spinlock is
> needed to stop the ip6_tnl_dst_set() side from removing the refcnt.

Are you telling me RCU should be banished from the kernel ? ;)
