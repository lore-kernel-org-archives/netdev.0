From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Set truesize in pskb_expand_head
Date: Fri, 24 Sep 2004 16:33:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924163328.7597352c.davem@davemloft.net>
References: <20040924232053.GA7807@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040924232053.GA7807@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 25 Sep 2004 09:20:53 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> In order for the skb trimming to work, we need to set truesize in
> pskb_expand_head.  This patch does exactly that.

I tried to warn people about this earlier in the netlink
NLMSG_GOODSIZE thread.... ho hum.

This change mucks up socket buffer accounting.

If you change skb->truesize, then when the kfree_skb(skb)
happens a different skb->truesize will be subtracted from
the socket buffer allocation than what was used when the
skb was first charged to the socket.

Basically, once a skb might potentially be charged to a
socket, you cannot change truesize unless you are extremely
careful.

This is another reason why I recommended to use a scratch
buffer, btw :-)
