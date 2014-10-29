From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: frags: remove the WARN_ON from
 inet_evict_bucket
Date: Wed, 29 Oct 2014 15:22:05 -0400 (EDT)
Message-ID: <20141029.152205.991532148243308939.davem@davemloft.net>
References: <1414455409.4845.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<1414489441-28578-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, eric.dumazet@gmail.com,
	chutzpah@gentoo.org
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45775 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755394AbaJ2TWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 15:22:07 -0400
In-Reply-To: <1414489441-28578-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Tue, 28 Oct 2014 10:44:01 +0100

> The WARN_ON in inet_evict_bucket can be triggered by a valid case:
> inet_frag_kill and inet_evict_bucket can be running in parallel on the
> same queue which means that there has been at least one more ref added
> by a previous inet_frag_find call, but inet_frag_kill can delete the
> timer before inet_evict_bucket which will cause the WARN_ON() there to
> trigger since we'll have refcnt!=1. Now, this case is valid because the
> queue is being "killed" for some reason (removed from the chain list and
> its timer deleted) so it will get destroyed in the end by one of the
> inet_frag_put() calls which reaches 0 i.e. refcnt is still valid.
> 
> CC: Florian Westphal <fw@strlen.de>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Patrick McLean <chutzpah@gentoo.org>
> 
> Fixes: b13d3cbfb8e8 ("inet: frag: move eviction of queues to work queue")
> Reported-by: Patrick McLean <chutzpah@gentoo.org>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
> I'm sending this as a separate patch so the race fix doesn't get blocked
> in case I'm wrong and also it's a different issue.

Also applied, thanks.
