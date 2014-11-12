From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] crypto: aesni-intel - avoid IPsec re-ordering
Date: Wed, 12 Nov 2014 10:12:16 +0100
Message-ID: <20141112091216.GM6390@secunet.com>
References: <1415771371-30774-1-git-send-email-ming.liu@windriver.com>
 <20141112084138.GL6390@secunet.com>
 <20141112085148.GA26268@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ming Liu <ming.liu@windriver.com>, <davem@davemloft.net>,
	<ying.xue@windriver.com>, <linux-crypto@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141112085148.GA26268@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 12, 2014 at 04:51:48PM +0800, Herbert Xu wrote:
> On Wed, Nov 12, 2014 at 09:41:38AM +0100, Steffen Klassert wrote:
> >
> > Can't we just use cryptd unconditionally to fix this reordering problem?
> 
> I think the idea is that most of the time cryptd isn't required
> so we want to stick with direct processing to lower latency.

Yes, I thought that. But is it really the case that doing it
asynchronous increases the latency? I tried this some time
ago and as far as I remember there was not too much difference
between the direct and the asynchronous case. Might depend
on the usecase of course.

> 
> I think the simplest fix would be to punt to cryptd as long as
> there are cryptd requests queued.

This would be the second option. We may need to adjust the
maximum cryptd queue lenght then, as the networking receive
softirq might enqueue a lot of packets before cryptd can
process them.
