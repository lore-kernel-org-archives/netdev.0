From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: Fix tipc_sk_reinit handling of -EAGAIN
Date: Thu, 24 Aug 2017 14:02:58 -0700 (PDT)
Message-ID: <20170824.140258.238955887232472310.davem@davemloft.net>
References: <1907606232.1152250.1503498773672.JavaMail.zimbra@redhat.com>
        <25145358.1155254.1503499382947.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, psutter@redhat.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rpeterso@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <25145358.1155254.1503499382947.JavaMail.zimbra@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bob Peterson <rpeterso@redhat.com>
Date: Wed, 23 Aug 2017 10:43:02 -0400 (EDT)

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

Applied and queued up for -stable, thanks.
