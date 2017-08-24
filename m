From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tipc: Fix tipc_sk_reinit handling of -EAGAIN
Date: Thu, 24 Aug 2017 21:10:56 +0800
Message-ID: <20170824131056.GC14926@gondor.apana.org.au>
References: <1907606232.1152250.1503498773672.JavaMail.zimbra@redhat.com>
 <25145358.1155254.1503499382947.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Sutter <psutter@redhat.com>, davem@davemloft.net,
        netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Bob Peterson <rpeterso@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:49098 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdHXNLN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 09:11:13 -0400
Content-Disposition: inline
In-Reply-To: <25145358.1155254.1503499382947.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 23, 2017 at 10:43:02AM -0400, Bob Peterson wrote:
> Hi,
> 
> In 9dbbfb0ab6680c6a85609041011484e6658e7d3c function tipc_sk_reinit
> had additional logic added to loop in the event that function
> rhashtable_walk_next() returned -EAGAIN. No worries.
> 
> However, if rhashtable_walk_start returns -EAGAIN, it does "continue",
> and therefore skips the call to rhashtable_walk_stop(). That has
> the effect of calling rcu_read_lock() without its paired call to
> rcu_read_unlock(). Since rcu_read_lock() may be nested, the problem
> may not be apparent for a while, especially since resize events may
> be rare. But the comments to rhashtable_walk_start() state:
> 
>  * ...Note that we take the RCU lock in all
>  * cases including when we return an error.  So you must always call
>  * rhashtable_walk_stop to clean up.
> 
> This patch replaces the continue with a goto and label to ensure a
> matching call to rhashtable_walk_stop().
> 
> Signed-off-by: Bob Peterson <rpeterso@redhat.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for catching this!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
