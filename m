From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 0/6] xfrm: convert xfrm_state_find to rcu
Date: Thu, 11 Aug 2016 13:13:01 +0200
Message-ID: <20160811111301.GD5710@gauss.secunet.com>
References: <1470737769-30438-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:48300 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828AbcHKLNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2016 07:13:05 -0400
Content-Disposition: inline
In-Reply-To: <1470737769-30438-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 09, 2016 at 12:16:03PM +0200, Florian Westphal wrote:
> This series converts state_by{dst,src,spi} to allow lookups without
> holding xfrm_state_lock.
> 
> Only xfrm_state_find() is converted here for the (more common) case where
> we do not query key manager.
> 
> Once more flows are created/destroyed (or the flow cache is overloaded and
> often cleans out other entries) this function (and the state lock)
> start to show up in perf.
> 
> Florian Westphal (6):
>       xfrm: state: use hlist_for_each_entry_rcu helper
>       xfrm: state: use atomic_inc_not_zero to increment refcount
>       xfrm: state: delay freeing until rcu grace period has elapsed
>       xfrm: state: add sequence count to detect hash resizes
>       xfrm: state: use rcu_deref and assign_pointer helpers
>       xfrm: state: don't use lock anymore unless acquire operation is needed
> 
>  include/net/netns/xfrm.h |    6 +-
>  net/xfrm/xfrm_state.c    |  103 +++++++++++++++++++++++++++++++----------------
>  2 files changed, 72 insertions(+), 37 deletions(-)

All applied to the ipsec-next tree, thanks Florian!
