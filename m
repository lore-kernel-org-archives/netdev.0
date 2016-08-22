From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Subject: [PATCH ipsec-next 0/8] xfrm: policy: convert lookups to
 rcu
Date: Mon, 22 Aug 2016 07:15:51 +0200
Message-ID: <20160822051551.GJ5710@gauss.secunet.com>
References: <1470921479-25592-1-git-send-email-fw@strlen.de>
 <20160812082254.GI5710@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:39442 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752758AbcHVFP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 01:15:57 -0400
Content-Disposition: inline
In-Reply-To: <20160812082254.GI5710@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2016 at 10:22:54AM +0200, Steffen Klassert wrote:
> On Thu, Aug 11, 2016 at 03:17:51PM +0200, Florian Westphal wrote:
> > Since commit d188ba86dd07a72eb ("xfrm: add rcu protection to sk->sk_policy[]")
> > sk_policy can rely on rcu protection.
> > 
> > This change allows to also use rcu in xfrm_policy_lookup_bytype and to
> > avoid grabbing the read-sie policy lock during lookups.
> > 
> > read-side policy rwlock is converted to pure rcu, then the policy_lock is
> > changed to a plain spinlock as only write-sides remain.
> > 
> > First few patches do some preparation work, the later ones remove
> > the read-side locks, last patch converts rwlock to spinlock.
> > 
> > I tested this with rcu debug enabled and simple esp tunnel
> > forwarding udp packets.
> > 
> > If you have better tests for this please let me know and I can re-run with
> > that.
> > 
> > Florian Westphal (8):
> >       xfrm: policy: use rcu versions for iteration and list add/del
> >       xfrm: policy: prepare policy_bydst hash for rcu lookups
> >       xfrm: policy: add sequence count to synchronize reads with hash resizes
> >       xfrm: policy: use atomic_inc_not_zero in rcu section
> >       xfrm: policy: make xfrm_policy_lookup_bytype lockless
> >       xfrm: policy: only use rcu in xfrm_sk_policy_lookup
> >       xfrm: policy: don't acquire policy lock in xfrm_spd_getinfo
> >       xfrm: policy: convert policy_lock to spinlock
> > 
> >  include/net/netns/xfrm.h |    4 -
> >  net/xfrm/xfrm_policy.c   |  145 +++++++++++++++++++++++++++--------------------
> >  2 files changed, 88 insertions(+), 61 deletions(-)
> 
> Looks good, I've applied to already to the ipsec-next testing branch.
> However, I'll be off for a week starting this afternoon, so I don't
> see if the patchset passed all tests before I leave. For that I defer
> the applying to master until I'm back.

Now applied to the ipsec-next tree, thanks a lot Florian!
