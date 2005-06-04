From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 14:00:21 +0400
Message-ID: <20050604140021.62259ad3@zanzibar.2ka.mipt.ru>
References: <20050603234623.GA20088@gondor.apana.org.au>
	<42A0EFAC.7070609@pobox.com>
	<20050604004201.GB20471@gondor.apana.org.au>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller"
 <davem@davemloft.net>,
        James Morris <jmorris@redhat.com>,
        Linux Crypto
 Mailing List <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050604004201.GB20471@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 4 Jun 2005 10:42:01 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi Jeff:
> 
> On Fri, Jun 03, 2005 at 08:02:52PM -0400, Jeff Garzik wrote:
> > 
> > A standard feature of struct scatterlist is having the DMA mappings 
> > right next to the kernel virtual address/length info.  Drivers use the 
> > arch-specific DMA-mapped part of struct scatterlist to fill the 
> > hardware-specific descriptions with addresses and other info.
> 
> Agreed.
> 
> > Since you -will- have to DMA map buffers before passing them to 
> > hardware, it seems like struct scatterlist is much more appropriate than 
> >  crypto_frag when dealing with hardware.
> > 
> > For pure software implementations, I don't see why you can't just ignore 
> > the extra fields that each arch puts into struct scatterlist.
> 
> It depends on who is going to do the mapping.  When we implement hardware
> crypto, the DMA mapping will be done either by the crypto layer or under
> it by the driver itself.  So the crypto layer is certainly going to need
> the scatterlist structure.
> 
> However, the users of the crypto layer (such as IPsec/dmcrypt) don't have
> to know about DMA at all.  Therefore the data structure between the users
> and the crypto layer itself doesn't have to carry DMA information.
> 
> Compare this with the block layer.  Between the users of the block layer
> and the block layer itself you have the bio_vec structure which carries
> no DMA information.  The scatterlist structure only comes into play after
> DMA mapping has been carried out under the block layer.
> 
> So this is really a sort of bio_vec for crypto structures.  The objective
> here is to make the structure as compact as possible to allow users to
> allocate it on the stack most of the time.

As far as I remember, IPsec has scterlists specially to _not_ remap
from any inner strucutre to scaterlist later.
Block layer was not designed in a such way because
there is no easy mapping in block cache into scaterlist
and bio_vec has much bigger usage than SA, so removing dma address
is suitable there.

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> -
> To unsubscribe from this list: send the line "unsubscribe linux-crypto" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
