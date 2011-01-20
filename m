From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 20 Jan 2011 00:46:34 -0800
Message-ID: <1295513194.1952.96.camel@Joe-Laptop>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295284788.21277.65.camel@Joe-Laptop>
	 <AANLkTi=nJxwR89CF3i0+L6+yM4Bg_PN8PQByTAHP2nPM@mail.gmail.com>
	 <1295455290.1952.22.camel@Joe-Laptop>
	 <AANLkTi=NU=ANUDGGdiCL+AP696nF1kXwPHOPZPrCti2u@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ratbert@faraday-tech.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, dilinger@queued.net
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=NU=ANUDGGdiCL+AP696nF1kXwPHOPZPrCti2u@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-01-20 at 13:30 +0800, Po-Yu Chuang wrote:
> One more question: how to deal with this? Add a local variable for the
> 2nd argument?
> 
> 	ftmac100_set_receive_ring_base(priv,
> 				       priv->descs_dma_addr + offsetof(struct ftmac100_descs, rxdes));

That's one way, another is:

	ftmac100_set_receive_ring_base(priv,
 				       priv->descs_dma_addr +
				       offsetof(struct ftmac100_descs, rxdes));

Another would be to change set_receive_ring_base to
just pass priv and determine the dma address there:

static void ftmac100_set_receive_ring_base(struct ftmac100 *priv)
{
	dma_addr_t addr;

	addr = priv->descs_dma_addr + offsetof(struct ftmac100_descs, rxdes);
	iowrite32(addr, priv->base + FTMAC100_OFFSET_RXR_BADR);
}
...
	ftmac100_set_receive_ring_base(priv);

Another is not to be overly adherent to 80 columns.

Pick one that suits you.

You chose to use a lot of single use, single line
functions with descriptive names that use iowrite32 or
return some flag.  I probably would have just used
iowrite32 or tested the flag directly, but that's your
choice and it's perfectly fine.

There are a lot of coding choices that are readable and
good.  There isn't and shouldn't be some mandate for some
specific code appearance before inclusion or acceptance.

checkpatch is just a style guide.  Ignore it and ignore
me when you feel it's appropriate.  I won't mind.

cheers, Joe
