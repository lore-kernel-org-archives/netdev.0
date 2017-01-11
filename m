From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next 0/6] xfrm: remove xfrm_state_get_afinfo
 conditional rcu locking
Date: Wed, 11 Jan 2017 13:17:37 +0100
Message-ID: <20170111121737.GF3541@gauss.secunet.com>
References: <1483968050-788-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36932 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965425AbdAKMRl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 07:17:41 -0500
Content-Disposition: inline
In-Reply-To: <1483968050-788-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2017 at 02:20:44PM +0100, Florian Westphal wrote:
> xfrm_state_get_afinfo still uses a conditional locking scheme
> dating back to when this still used an rwlock:
> 
> If return value is NULL, no lock (rcu readlock) was taken,
> otherwise, rcu_read_unlock has to be called.
> 
> This series moves rcu read lock/unlock responsibility to the callers.
> 
> xfrm_state_put_afinfo is removed (it is equivalent
> to rcu_read_unlock so thats what will be used instead).
> 
> xfrm_state_get_afinfo is renamed to xfrm_state_afinfo_get_rcu()
> and is only a rcu dereference wrapper.
> 
> In one case, rcu read/unlock can be avoided as we're always
> called with rcu read lock held.

All applied to ipsec-next, thanks a lot!
