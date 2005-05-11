From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netlink: defer socket destruction a bit
Date: Thu, 12 May 2005 09:03:09 +1000
Message-ID: <20050511230309.GA21547@gondor.apana.org.au>
References: <428284D6.9000804@tpack.net> <20050511222421.GA21331@gondor.apana.org.au> <4282889A.7080409@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <4282889A.7080409@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2005 at 12:35:06AM +0200, Tommy Christensen wrote:
> 
> No, skb2 cannot be shared with a listening socket. As I read the code,
> it can only be non-null when delivery has failed.

What about this code path:

1) skb2 = skb, refcnt++.
2) Devliered to socket 1.
3) Socket 1 frees skb through recvmsg.
4) skb2 = skb, refcnt++.
5) Delivery fails.

Now skb2 is identical to skb and they both refer to socket 1.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
