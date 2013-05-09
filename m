From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: conntrack: remove the central
 spinlock
Date: Wed, 08 May 2013 23:01:41 -0700
Message-ID: <1368079301.13473.88.camel@edumazet-glaptop>
References: <1368068665.13473.81.camel@edumazet-glaptop>
	 <kmfd2s$e2m$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:41880 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815Ab3EIGBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 02:01:44 -0400
In-Reply-To: <kmfd2s$e2m$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-09 at 05:43 +0000, Cong Wang wrote:
> On Thu, 09 May 2013 at 03:04 GMT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >  
> > +#if 0
> > +	for (i = 0; i < ARRAY_SIZE(nf_conntrack_locks); i++)
> > +		arch_spin_lock_init(&nf_conntrack_locks[i]);
> > +#endif
> > +
> 
> Is this intentional?

What do you think ?

Apparently arch_spin_lock_init() does not exist (but for ia64)

kernel/lglock.c simply relies on storage being cleared.

nf_conntrack_locks[] being cleared, we do not have to init it.

But I do not really like this.
