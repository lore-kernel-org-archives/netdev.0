From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH nf-next] netns: add and use net_ns_barrier
Date: Wed, 31 May 2017 12:55:27 -0400 (EDT)
Message-ID: <20170531.125527.1553231867217469072.davem@davemloft.net>
References: <20170530093812.10712-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        ebiederm@xmission.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41068 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdEaQz3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 12:55:29 -0400
In-Reply-To: <20170530093812.10712-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 30 May 2017 11:38:12 +0200

> Quoting Joe Stringer:
>   If a user loads nf_conntrack_ftp, sends FTP traffic through a network
>   namespace, destroys that namespace then unloads the FTP helper module,
>   then the kernel will crash.
> 
> Events that lead to the crash:
> 1. conntrack is created with ftp helper in netns x
> 2. This netns is destroyed
> 3. netns destruction is scheduled
> 4. netns destruction wq starts, removes netns from global list
> 5. ftp helper is unloaded, which resets all helpers of the conntracks
> via for_each_net()
> 
> but because netns is already gone from list the for_each_net() loop
> doesn't include it, therefore all of these conntracks are unaffected.
> 
> 6. helper module unload finishes
> 7. netns wq invokes destructor for rmmod'ed helper
> 
> CC: "Eric W. Biederman" <ebiederm@xmission.com>
> Reported-by: Joe Stringer <joe@ovn.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Eric, I'd like an explicit (n)ack from you for this one.

Indeed, Eric, please do.

Otherwise I'm fine with the generic parts:

Acked-by: David S. Miller <davem@davemloft.net>
