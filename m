From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] connector/userns: replace netlink uses of
 cap_raised() with capable()
Date: Thu, 10 May 2012 23:21:56 -0400 (EDT)
Message-ID: <20120510.232156.402883000515302167.davem@davemloft.net>
References: <20120504213403.BD3A4A0367@akpm.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, dhowells@redhat.com,
	james.l.morris@oracle.com, kaber@trash.net, morgan@kernel.org,
	philipp.reisner@linbit.com, segoon@openwall.com,
	serge.hallyn@canonical.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932255Ab2EKDXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 23:23:34 -0400
In-Reply-To: <20120504213403.BD3A4A0367@akpm.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 04 May 2012 14:34:03 -0700

> In 2009 Philip Reiser notied that a few users of netlink connector
> interface needed a capability check and added the idiom
> cap_raised(nsp->eff_cap, CAP_SYS_ADMIN) to a few of them, on the premise
> that netlink was asynchronous.
> 
> In 2011 Patrick McHardy noticed we were being silly because netlink is
> synchronous and removed eff_cap from the netlink_skb_params and changed
> the idiom to cap_raised(current_cap(), CAP_SYS_ADMIN).
> 
> Looking at those spots with a fresh eye we should be calling
> capable(CAP_SYS_ADMIN).  The only reason I can see for not calling capable
> is that it once appeared we were not in the same task as the caller which
> would have made calling capable() impossible.
> 
> In the initial user_namespace the only difference between between
> cap_raised(current_cap(), CAP_SYS_ADMIN) and capable(CAP_SYS_ADMIN) are a
> few sanity checks and the fact that capable(CAP_SYS_ADMIN) sets
> PF_SUPERPRIV if we use the capability.
> 
> Since we are going to be using root privilege setting PF_SUPERPRIV seems
> the right thing to do.
> 
> The motivation for this that patch is that in a child user namespace
> cap_raised(current_cap(),...) tests your capabilities with respect to that
> child user namespace not capabilities in the initial user namespace and
> thus will allow processes that should be unprivielged to use the kernel
> services that are only protected with cap_raised(current_cap(),..).
> 
> To fix possible user_namespace issues and to just clean up the code
> replace cap_raised(current_cap(), CAP_SYS_ADMIN) with
> capable(CAP_SYS_ADMIN).
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Philipp Reisner <philipp.reisner@linbit.com>
> Acked-by: Serge E. Hallyn <serge.hallyn@canonical.com>
> Acked-by: Andrew G. Morgan <morgan@kernel.org>
> Cc: Vasiliy Kulikov <segoon@openwall.com>
> Cc: David Howells <dhowells@redhat.com>
> Reviewed-by: James Morris <james.l.morris@oracle.com>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks.
