From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Super TSO v2
Date: Mon, 23 May 2005 11:43:31 -0700 (PDT)
Message-ID: <20050523.114331.104031931.davem@davemloft.net>
References: <20050520.115154.48807299.davem@davemloft.net>
	<20050523095417.GA18770@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050523095417.GA18770@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 23 May 2005 19:54:17 +1000

> Perhaps we should set the goal based on the cwnd as we do now?
> 
> As it is I believe we may be doing more work compared to the
> status quo because it's always building 64K blocks and then
> cutting them up as dictated by the cwnd.  On the other hand, the
> current code simply builds the packets up to the size that cwnd
> allows.

I played with this, and it makes no difference.

It would only help when:

1) we are building sk->sk_send_head, and
2) sk->sk_send_head is the tail of the write queue

But the SKB splitting is so cheap that it doesn't
show up.

And if we sleep or defer for some reason, say while copying the data
from userspace or whatever, all of this information changes and we
don't bunch up as much as we could have.

Also, in my current code we defer sending not just at ACK arrive
processing, but also when doing normal sends from sendmsg() and
sendpages().  Which totally invalidates your suggested scheme :-)
