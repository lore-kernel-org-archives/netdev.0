From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETLINK] Fix multicast bind/autobind race
Date: Mon, 14 Mar 2005 21:28:45 -0800
Message-ID: <20050314212845.6a7fd240.davem@davemloft.net>
References: <20050314094420.GA15349@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050314094420.GA15349@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Mar 2005 20:44:20 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> netlink_autobind has always set nlk_sk(sk)->groups to zero.  This is
> unnecessary because sk_alloc already zeroes the entire structure.
> Since a socket can only be bound once netlink_autobind doesn't need
> to zero groups at all.
> 
> This had been safe until I added mc_list.  Now it is possible for
> netlink_bind to race against netlink_autobind running on the same
> socket on another CPU.  The result would be a socket that's on
> mc_list with groups set to zero.  This socket will be left on the
> list even after it is destroyed.
> 
> The fix is to remove the zeroing in netlink_autobind.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.

I suspect a 2.4.x version is necessary as well.  Could you cook
one up for me?  Thanks.
