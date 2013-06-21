From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v7] ethernet/arc/arc_emac - Add new driver
Date: Fri, 21 Jun 2013 17:22:34 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B729F@saturn3.aculab.com>
References: <1371799241-27771-1-git-send-email-abrodkin@synopsys.com> <4881796E12491D4BB15146FE0209CE643F5F587E@DE02WEMBXB.internal.synopsys.com> <1371825813.19215.34.camel@joe-AO722> <201306211758.26094.arnd@arndb.de> <1371830716.19215.37.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Alexey Brodkin" <Alexey.Brodkin@synopsys.com>,
	<netdev@vger.kernel.org>,
	"Andy Shevchenko" <andy.shevchenko@gmail.com>,
	"Francois Romieu" <romieu@fr.zoreil.com>,
	"Vineet Gupta" <Vineet.Gupta1@synopsys.com>,
	"Mischa Jonker" <Mischa.Jonker@synopsys.com>,
	"Grant Likely" <grant.likely@linaro.org>,
	"Rob Herring" <rob.herring@calxeda.com>,
	"Paul Gortmaker" <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	"Florian Fainelli" <florian@openwrt.org>
To: "Joe Perches" <joe@perches.com>, "Arnd Bergmann" <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55827 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1423180Ab3FUQXj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 12:23:39 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 32261-02 for <netdev@vger.kernel.org>;
 Fri, 21 Jun 2013 17:23:37 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1371830716.19215.37.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So it should be declared dma_addr_t then,
> 
> > +               addr = dma_map_single(&ndev->dev, (void *)rx_buff->skb->data,
> > +                                     buflen, DMA_FROM_DEVICE);
> > +               if (dma_mapping_error(&ndev->dev, addr)) {
> > +                       if (net_ratelimit())
> > +                               netdev_err(ndev, "cannot dma map\n");
> > +                       dev_kfree_skb(rx_buff->skb);
> > +                       stats->rx_errors++;
> > +                       continue;
> > +               }
> > +               dma_unmap_addr_set(&rx_buff, mapping, addr);
> > +               dma_unmap_len_set(&rx_buff, len, buflen);
> > +
> > +               rxbd->data = (unsigned char *)cpu_to_le32(rx_buff->skb->data);
> >
> > the 'addr' returned by dma_map_single is what the device really
> > needs, although it is the same as rx_buff->skb->data with the
> > trivial definition of dma_map_single.
> >
> > The last line here needs to be
> >                 rxbd->data = cpu_to_le32(addr);
> >
> > which fixes the bug, and has no dependency on a 32 bit CPU.
> 
> It still has a dependency on dma_addr_t size being 32 bit

No - just a dependency on memory being mapped to a 32bit
physical address accessible from the device.
Many 64 bit systems have devices that can only access 32bit
address space, either the memory has to be allocated from the
correct arena, of DMA bounce buffers are used.

	David
