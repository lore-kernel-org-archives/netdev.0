From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2/2] [NET] Add skb_header_cloned and use it in e1000/tg3
Date: Tue, 15 Feb 2005 10:33:12 -0800
Message-ID: <20050215103312.6178385f.davem@davemloft.net>
References: <20050121204024.6f94fc26.davem@davemloft.net>
	<20050122054346.GA1635@gondor.apana.org.au>
	<20050122170533.GB11499@yakov.inr.ac.ru>
	<20050123071027.GA20296@gondor.apana.org.au>
	<20050126110043.GA29950@yakov.inr.ac.ru>
	<20050126222522.GA21670@gondor.apana.org.au>
	<20050127110946.GA20494@gondor.apana.org.au>
	<20050127111201.GB20494@gondor.apana.org.au>
	<20050128202542.GA23670@yakov.inr.ac.ru>
	<20050129031740.GA6130@gondor.apana.org.au>
	<20050129032210.GA7424@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050129032210.GA7424@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 29 Jan 2005 14:22:10 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch then uses this function in e1000/tg3 to copy the data before
> the TCP/IP header is modified.

The tg3 version creates an SKB leak.  If pskb_expand_head() fails, we just
unlock and return NETDEV_TX_OK.  The upper layer assumes the driver took
ownership of the SKB in such a case.  I would recommend just kfree_skb()'ing
the thing when this happens.
