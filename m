From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [4/4] [IPSEC] Store MTU at each xfrm_dst
Date: Sun, 6 Mar 2005 21:32:14 -0800
Message-ID: <20050306213214.7d8a143d.davem@davemloft.net>
References: <20050214221006.GA18415@gondor.apana.org.au>
	<20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050214221607.GC18465@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Feb 2005 09:16:07 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Finally this is the patch that sets the MTU values of each xfrm_dst
> and keeps it up-to-date.
>   
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> To recap, at this point we've obtained accurate MTU values at each
> xfrm_dst.  The next step would be to start using it as
> dst_pmtu(xfrm_dst).

Applied, but with a bug fix:

+		mtu = dst_pmtu(xdst->route);
+		if (xdst->child_mtu_cached != mtu) {
+			last = xdst;
+			xdst->route_mtu_cached = mtu;
+		}

You obviously meant "route_mtu_cached" in the test,
not child_mtu_cached.
