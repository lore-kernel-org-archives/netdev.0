From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: pppoe and receive checksum offload
Date: Mon, 28 Feb 2005 17:04:01 +0300
Message-ID: <20050228140401.GA27937@yakov.inr.ac.ru>
References: <20050224155906.73890361@dxpl.pdx.osdl.net> <20050228113106.GA3268@gondor.apana.org.au> <20050228113938.GA3393@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, mostrows@speakeasy.net,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050228113938.GA3393@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Actually ip_gre is probably right.  It seems that CHECKSUM_UNNECESSARY
> should not be set for PPPOE/GRE packets at all.  So it would be a bug in
> the sk* driver.
> 
> Alexey/Dave, is this interpretation of ip_summed correct?

What's about CHECKSUM_UNNECESSARY, yes, it is set only for TCP/UDP packets,
when device verifies the checksum itself. It is not the case for
PPOE frames. CHECKSUM_HW is more flxible, ipip/gre tunnels use this adjusting
skb->csum by checksum of stripped headers.

ppp_input() could do the same thing. It does not, hence suggested patch
is corrrect minimal solution.

Alexey
