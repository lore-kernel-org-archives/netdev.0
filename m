From: "David S. Miller" <davem@davemloft.net>
Subject: Re: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at
 net/netlink/af_netlink.c (126)
Date: Wed, 30 Mar 2005 17:02:36 -0800
Message-ID: <20050330170236.2bddf666.davem@davemloft.net>
References: <20050327091524.GA23215@elte.hu>
	<E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au>
	<20050327133811.GA5569@elte.hu>
	<20050329104906.GA19836@gondor.apana.org.au>
	<20050329114926.GA14986@elte.hu>
	<20050330082640.GA8269@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, netdev@oss.sgi.com, linux-net@vger.kernel.org,
	olel@ans.pl
Return-path: <linux-net-owner@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050330082640.GA8269@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Mar 2005 18:26:40 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> In netlink_dump we're operating on sk after dropping the cb lock.
> This is racy because the owner of the socket could close it after
> we drop the cb lock.
> 
> This is possible because netlink_dump isn't always called from the
> context of the process that owns the socket.  For instance, if there
> is contention on rtnl then rtnetlink requests will be processed by
> the process that owns the rtnl.
> 
> The solution is to hold a ref count on the socket before we drop
> the cb lock.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.

Looks like 2.4.x needs the same fix, correct?
