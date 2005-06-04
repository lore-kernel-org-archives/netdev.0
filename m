From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Fri, 03 Jun 2005 20:02:52 -0400
Message-ID: <42A0EFAC.7070609@pobox.com>
References: <20050603234623.GA20088@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@redhat.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050603234623.GA20088@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> The Crypto API doesn't need all the data contained in a scatterlist
> structure.  For instance, it has no need for anything to do with DMA.
> When we implement hardware crypto (which might do DMA), they're going
> to have their own lists of descriptors so they can't use the scatterlist
> as is anyway.


I'm not sure I agree with this.

A standard feature of struct scatterlist is having the DMA mappings 
right next to the kernel virtual address/length info.  Drivers use the 
arch-specific DMA-mapped part of struct scatterlist to fill the 
hardware-specific descriptions with addresses and other info.

Since you -will- have to DMA map buffers before passing them to 
hardware, it seems like struct scatterlist is much more appropriate than 
  crypto_frag when dealing with hardware.

For pure software implementations, I don't see why you can't just ignore 
the extra fields that each arch puts into struct scatterlist.

	Jeff
