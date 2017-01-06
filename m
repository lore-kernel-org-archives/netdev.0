From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next] xfrm: state: do not acquire lock in get_mtu
 helpers
Date: Fri, 6 Jan 2017 12:35:29 +0100
Message-ID: <20170106113529.GC3541@gauss.secunet.com>
References: <1483619038-17586-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:55856 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933683AbdAFLfd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 06:35:33 -0500
Content-Disposition: inline
In-Reply-To: <1483619038-17586-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 05, 2017 at 01:23:58PM +0100, Florian Westphal wrote:
> Once flow cache gets removed the mtu initialisation happens for every skb
> that gets an xfrm attached, so this lock starts to show up in perf.
> 
> It is not obvious why this lock is required -- the caller holds
> reference on the state struct, type->destructor is only called from the
> state gc worker (all state structs on gc list must have refcount 0).
> 
> xfrm_init_state already has been called (else private data accessed
> by type->get_mtu() would not be set up).
> 
> So just remove the lock -- the race on the state (DEAD?) doesn't
> matter (could change right after dropping the lock too).
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied to ipsec-next, thanks Florian!
