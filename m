From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] netlink: defer socket destruction a bit
Date: Thu, 12 May 2005 11:57:01 +0200
Message-ID: <1115891821.30106.86.camel@tsc-6.cph.tpack.net>
References: <428284D6.9000804@tpack.net>
	 <20050511222421.GA21331@gondor.apana.org.au> <4282889A.7080409@tpack.net>
	 <20050511230309.GA21547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050511230309.GA21547@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-05-12 at 01:03, Herbert Xu wrote:
> On Thu, May 12, 2005 at 12:35:06AM +0200, Tommy Christensen wrote:
> > 
> > No, skb2 cannot be shared with a listening socket. As I read the code,
> > it can only be non-null when delivery has failed.
> 
> What about this code path:
> 
> 1) skb2 = skb, refcnt++.
> 2) Devliered to socket 1.
> 3) Socket 1 frees skb through recvmsg.
> 4) skb2 = skb, refcnt++.
> 5) Delivery fails.
> 
> Now skb2 is identical to skb and they both refer to socket 1.

You're right, Herbert.  The interception by recvmsg has to be
considered in this case also.  Tricky.

I moved the call to skb_orphan in the other patch, as you
suggested.  I think that also makes this patch safe as it is.

Right?

-Tommy
