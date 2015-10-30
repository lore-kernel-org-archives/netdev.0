From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2015-10-30
Date: Fri, 30 Oct 2015 20:53:05 +0900 (KST)
Message-ID: <20151030.205305.233341348283456604.davem@davemloft.net>
References: <1446185790-24214-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758909AbbJ3LxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 07:53:17 -0400
In-Reply-To: <1446185790-24214-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 30 Oct 2015 07:16:25 +0100

> 1) The flow cache is limited by the flow cache limit which
>    depends on the number of cpus and the xfrm garbage collector
>    threshold which is independent of the number of cpus. This
>    leads to the fact that on systems with more than 16 cpus
>    we hit the xfrm garbage collector limit and refuse new
>    allocations, so new flows are dropped. On systems with 16
>    or less cpus, we hit the flowcache limit. In this case, we
>    shrink the flow cache instead of refusing new flows. 
> 
>    We increase the xfrm garbage collector threshold to INT_MAX
>    to get the same behaviour, independent of the number of cpus.
> 
> 2) Fix some unaligned accesses on sparc systems.
>    From Sowmini Varadhan.
> 
> 3) Fix some header checks in _decode_session4. We may call
>    pskb_may_pull with a negative value converted to unsigened
>    int from pskb_may_pull. This can lead to incorrect policy
>    lookups. We fix this by a check of the data pointer position
>    before we call pskb_may_pull.
> 
> 4) Reload skb header pointers after calling pskb_may_pull
>    in _decode_session4 as this may change the pointers into
>    the packet. 
> 
> 5) Add a missing statistic counter on inner mode errors.
> 
> Please pull or let me know if there are problems.
 ...
>   git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

Pulled, thanks a lot Steffen!
