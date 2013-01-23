From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] net: add RCU annotation to sk_dst_cache field
Date: Wed, 23 Jan 2013 12:58:06 +0800
Message-ID: <1358917086.4235.12.camel@cr0>
References: <1358916229-19004-1-git-send-email-amwang@redhat.com>
	 <1358916659.12374.684.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17058 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752872Ab3AWE6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 23:58:13 -0500
In-Reply-To: <1358916659.12374.684.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-22 at 20:50 -0800, Eric Dumazet wrote:
> On Wed, 2013-01-23 at 12:43 +0800, Cong Wang wrote:
> > From: Cong Wang <amwang@redhat.com>
> > 
> > sock->sk_dst_cache is protected by RCU.
> > 
> > Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> > 
> > ---
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index 5a34e2f..c4b64c6 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -337,7 +337,7 @@ struct sock {
> >  #endif
> >  	unsigned long 		sk_flags;
> >  	struct dst_entry	*sk_rx_dst;
> > -	struct dst_entry	*sk_dst_cache;
> > +	struct dst_entry __rcu	*sk_dst_cache;
> >  	spinlock_t		sk_dst_lock;
> >  	atomic_t		sk_wmem_alloc;
> >  	atomic_t		sk_omem_alloc;
> 
> Thats not a complete patch.
> 
> You'll have to fix the errors it brings.

It does fix this warning:

net/core/flow_dissector.c:280:37: sparse: incompatible types in
comparison expression (different address spaces)
