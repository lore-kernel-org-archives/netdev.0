From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2/2] [NET] Add skb_header_cloned and use it in e1000/tg3
Date: Wed, 23 Feb 2005 19:51:37 -0800
Message-ID: <20050223195137.1e769c77.davem@davemloft.net>
References: <20050122170533.GB11499@yakov.inr.ac.ru>
	<20050123071027.GA20296@gondor.apana.org.au>
	<20050126110043.GA29950@yakov.inr.ac.ru>
	<20050126222522.GA21670@gondor.apana.org.au>
	<20050127110946.GA20494@gondor.apana.org.au>
	<20050127111201.GB20494@gondor.apana.org.au>
	<20050128202542.GA23670@yakov.inr.ac.ru>
	<20050129031740.GA6130@gondor.apana.org.au>
	<20050129032210.GA7424@gondor.apana.org.au>
	<20050215103312.6178385f.davem@davemloft.net>
	<20050215202453.GA4355@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050215202453.GA4355@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Feb 2005 07:24:53 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Feb 15, 2005 at 10:33:12AM -0800, David S. Miller wrote:
> > 
> > The tg3 version creates an SKB leak.  If pskb_expand_head() fails, we just
> > unlock and return NETDEV_TX_OK.  The upper layer assumes the driver took
> > ownership of the SKB in such a case.  I would recommend just kfree_skb()'ing
> > the thing when this happens.
> 
> Indeed.  Here is the corrected version.
> 
> This patch adds skb_header_cloned which tells us whether we need to
> copy the data before we can modify the header part of the skb.  Again,
> what constitutes the header is left up to the users of the skb to define.
> 
> This patch then uses this function in e1000/tg3 to copy the data before
> the TCP/IP header is modified.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also queued to 2.6.12, thanks.  Someone should cook up the versions
for other drivers supporting TSO.
