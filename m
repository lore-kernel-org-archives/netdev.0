From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] Move hardware headers for decaped packets
Date: Sun, 7 Dec 2003 16:55:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031207165516.1edfde10.davem@redhat.com>
References: <20030925121131.GA17968@gondor.apana.org.au>
	<200309251228.QAA11650@yakov.inr.ac.ru>
	<20030925124102.GA18188@gondor.apana.org.au>
	<20031207090205.GA2358@gondor.apana.org.au>
	<20031207014714.03e79cd2.davem@redhat.com>
	<20031207095527.GA2767@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031207095527.GA2767@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 7 Dec 2003 20:55:27 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sun, Dec 07, 2003 at 01:47:14AM -0800, David S. Miller wrote:
> >
> > Ok, I'll review this again.  Did you audit the tree to make sure you
> > updated mac_len everywhere that 'skb->mac.*' is modified?
> 
> To be honest, no.  The reason is that my use of mac_len starts from
> netif_receive_skb and ends just before the reentrance into netif_rx
> in xfrm[46]_input.
> 
> At the start of that path, mac_len is initialised from a value that
> we know to be correct.  I have also verified that within the path,
> nobody expands/contracts the MAC header.

Ok, we can make it a receive only thing at first, I guess.

But I think this will definitely need to be deferred to
2.6.1 at least, along with that XFRM device unload fix you
sent me the other week.

Linus really only wants the obvious one-liners at this point
for 2.6.0

Thanks.
