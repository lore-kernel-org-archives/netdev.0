From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Sat, 30 Apr 2005 11:02:48 +1000
Message-ID: <E1DRgNc-00067H-00@gondolin.me.apana.org.au>
References: <1114821473.24687.404.camel@localhost.localdomain>
Cc: markb@wetlettuce.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: alan@lxorguk.ukuu.org.uk (Alan Cox)
In-Reply-To: <1114821473.24687.404.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> On Iau, 2005-04-28 at 21:42, Mark Broadbent wrote:
>> The interrupt handling code in the tulip network driver appears to use a non 
>> IRQ safe spinlock in an interrupt context.  The following patch should correct 
>> this.
> 
> In what situations is this code path executed outside the IRQ handler ?

Only through poll_tulip via netpoll.  However, that is safe as well
since poll_tulip does a disable_irq(dev->irq).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
