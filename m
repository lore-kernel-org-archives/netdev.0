From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net: sk_clone_lock() should only do get_net()
 if the parent is not a kernel socket
Date: Thu, 30 Jul 2015 16:00:06 -0700 (PDT)
Message-ID: <20150730.160006.1603147920495272496.davem@davemloft.net>
References: <20150730135036.GA17366@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com, willemb@google.com, ebiederm@xmission.com,
	alexander.h.duyck@intel.com, ast@plumgrid.com,
	hannes@stressinduktion.org, dborkman@redhat.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbbG3XAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 19:00:07 -0400
In-Reply-To: <20150730135036.GA17366@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 30 Jul 2015 15:50:36 +0200

> 
> 
> The newsk returned by sk_clone_lock should hold a get_net()
> reference if, and only if, the parent is not a kernel socket
> (making this similar to sk_alloc()).
> 
> E.g,. for the SYN_RECV path, tcp_v4_syn_recv_sock->..inet_csk_clone_lock
> sets up the syn_recv newsk from sk_clone_lock. When the parent (listen)
> socket is a kernel socket (defined in sk_alloc() as having
> sk_net_refcnt == 0), then the newsk should also have a 0 sk_net_refcnt
> and should not hold a get_net() reference.
> 
> Fixes: 26abe14379f8 ("net: Modify sk_alloc to not reference count the
>       netns of kernel sockets.")
> Acked-by: Eric Dumazet <edumazet@google.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2: pulled patch #3 out of the RFC patch-set for RDS-TCP netns fixes; 
>     Added Fixes, Acked-by, Cc fields based on mailing list feedback
>     from Eric Dumazet.

Applied, thanks everyone.
