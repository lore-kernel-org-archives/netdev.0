From: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [RFC/PATCH] remove unneeded check in bcm43xx
Date: Wed, 12 Apr 2006 08:35:39 +1000
Message-ID: <1144794939.19353.63.camel@localhost.localdomain>
References: <1144719972.19353.24.camel@localhost.localdomain>
	 <20060410.224933.39567033.davem@davemloft.net>
	 <1144788541.19353.41.camel@localhost.localdomain>
	 <20060411.143407.74615246.davem@davemloft.net>
	 <1144794077.19353.53.camel@localhost.localdomain>
	 <20060411223024.GA6543@ens-lyon.fr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
   netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
   linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Benoit Boissinot <benoit.boissinot-vYW+cPY1g1pg9hUCZPvPmw@public.gmane.org>
In-Reply-To: <20060411223024.GA6543-vYW+cPY1g1pWj0EZb7rXcA@public.gmane.org>
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

On Wed, 2006-04-12 at 00:30 +0200, Benoit Boissinot wrote:
> On Wed, Apr 12, 2006 at 08:21:17AM +1000, Benjamin Herrenschmidt wrote:
> > 
> > > I still think we shouldn't reward shit hardware by complicating
> > > up our DMA mappings internals. :-)
> > 
> > BTW. In the meantime, can't that driver work in PIO only mode ?
> 
> yes, I think you just have to have the pci_set_dma_mask fail with
> DMA30BIT_MASK.

Ok, _that_ makes sense in fact to have ppc do that when the mask is too
big... now the problem is should I compare the mask to the available
RAM ? That is, there is little point in failing for a 30 bits mask if
hte machine only has 512M of RAM.

By extension of the above, what to do on 32 bits kernels, should I test
the mask against total memory or specifically against lowmem ? There is
no clear answer here as some drivers will get highmem pages for DMA,
just not network drivers afaik (block drivers will), though I can't be
sure what will happen with thing like nbd... I'm not familiar enough
with the network stack. It would be sad to have 32 bits laptop switch to
PIO when they have too much RAM if, in practice, skbs are always only in
lowmem..

I think for now, what I may do is just add such a test for ppc64 and not
ppc32 and will talk to paulus see if he happens to have a better idea.

It's all very sad that bcm gets away with such crap though and that so
many vendors just bought it without complaining...

Ben.
