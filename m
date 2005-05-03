From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETLINK] cb_lock does not needs ref count on sk
Date: Tue, 3 May 2005 14:42:44 -0700
Message-ID: <20050503144244.1efdfd0c.davem@davemloft.net>
References: <20050327091524.GA23215@elte.hu>
	<E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au>
	<20050327133811.GA5569@elte.hu>
	<20050329104906.GA19836@gondor.apana.org.au>
	<20050329114926.GA14986@elte.hu>
	<20050330082640.GA8269@gondor.apana.org.au>
	<20050330170236.2bddf666.davem@davemloft.net>
	<20050331231922.GA26587@gondor.apana.org.au>
	<20050331232322.GA26693@gondor.apana.org.au>
	<20050331203313.57e1c5c3.davem@davemloft.net>
	<20050401093633.GA32707@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050401093633.GA32707@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 1 Apr 2005 19:36:33 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is a little optimisation for the cb_lock used by netlink_dump.
> While fixing that race earlier, I noticed that the reference count
> held by cb_lock is completely useless.  The reason is that in order
> to obtain the protection of the reference count, you have to take
> the cb_lock.  But the only way to take the cb_lock is through
> dereferencing the socket.
> 
> That is, you must already possess a reference count on the socket
> before you can take advantage of the reference count held by cb_lock.
> As a corollary, we can remve the reference count held by the cb_lock.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good, applied.
