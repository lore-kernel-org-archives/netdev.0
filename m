From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 8 Aug 2007 15:55:03 +0200
Message-ID: <200708081555.03588.mb@bu3sch.de>
References: <200708080045.l780jE9E004667@neteffect.com> <20070808133850.GE14419@one.firstfloor.org> <200708081548.25399.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, ggrundstrom@neteffect.com,
	rdreier@cisco.com, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:58080
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414AbXHHN4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 09:56:02 -0400
In-Reply-To: <200708081548.25399.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 08 August 2007 15:48:25 Michael Buesch wrote:
> > However if that's true then there are quite some drivers wrong:
> > 
> > % grep -r write[bwl]\(cpu_to *   | wc -l
> > 57
> 
> Yeah, seems so.

Most of them seem to be
 __raw_writew(cpu_toXX(...

which I think might be valid.
But there are indeed a few cases that look wrong.

arch/mips/pci/ops-bonito64.c:           writel(cpu_to_le32(*data), addrp);
arch/x86_64/kernel/pci-calgary.c:       writel(cpu_to_be32(val), target);
arch/x86_64/kernel/pci-calgary.c:       writel(cpu_to_be32(val), target);
arch/x86_64/kernel/pci-calgary.c:               writel(cpu_to_be32(val32), target);
arch/x86_64/kernel/pci-calgary.c:       writel(cpu_to_be32(val), target);
arch/x86_64/kernel/pci-calgary.c:       writel(cpu_to_be32(val32), target);
arch/x86_64/kernel/pci-calgary.c:       writel(cpu_to_be32(val32), target);
drivers/atm/fore200e.c:    writel(cpu_to_le32(val), addr);
drivers/net/starfire.c:         writew(cpu_to_be16(eaddrs[2]), setup_frm); setup_frm += 4;
drivers/net/starfire.c:         writew(cpu_to_be16(eaddrs[1]), setup_frm); setup_frm += 4;
drivers/net/starfire.c:         writew(cpu_to_be16(eaddrs[0]), setup_frm); setup_frm += 8;
drivers/net/starfire.c:                         writew(cpu_to_be16(i), filter_addr);
drivers/net/starfire.c:                 writew(cpu_to_be16(eaddrs[2]), filter_addr); filter_addr += 4;
drivers/net/starfire.c:                 writew(cpu_to_be16(eaddrs[1]), filter_addr); filter_addr += 4;
drivers/net/starfire.c:                 writew(cpu_to_be16(eaddrs[0]), filter_addr); filter_addr += 8;
drivers/net/starfire.c:                 writew(cpu_to_be16(eaddrs[0]), filter_addr); filter_addr += 4;
drivers/net/starfire.c:                 writew(cpu_to_be16(eaddrs[1]), filter_addr); filter_addr += 4;
drivers/net/starfire.c:                 writew(cpu_to_be16(eaddrs[2]), filter_addr); filter_addr += 8;
drivers/net/starfire.c:                 writew(cpu_to_be16(eaddrs[0]), filter_addr); filter_addr += 4;
drivers/net/starfire.c:                 writew(cpu_to_be16(eaddrs[1]), filter_addr); filter_addr += 4;
drivers/net/starfire.c:                 writew(cpu_to_be16(eaddrs[2]), filter_addr); filter_addr += 8;
drivers/net/hamachi.c:  writel(cpu_to_le64(hmp->rx_ring_dma), ioaddr + RxPtr);
drivers/net/hamachi.c:  writel(cpu_to_le64(hmp->rx_ring_dma) >> 32, ioaddr + RxPtr + 4);
drivers/net/hamachi.c:  writel(cpu_to_le64(hmp->tx_ring_dma), ioaddr + TxPtr);
drivers/net/hamachi.c:  writel(cpu_to_le64(hmp->tx_ring_dma) >> 32, ioaddr + TxPtr + 4);
drivers/net/hamachi.c:  writel(cpu_to_le32(hmp->rx_ring_dma), ioaddr + RxPtr);
drivers/net/hamachi.c:  writel(cpu_to_le32(hmp->tx_ring_dma), ioaddr + TxPtr);
drivers/net/tokenring/lanstreamer.c:            writel(cpu_to_le32(pci_map_single(streamer_priv->pci_dev, rx_ring, 512, PCI_DMA_FROMDEVICE)),
drivers/net/tokenring/lanstreamer.c:    writel(cpu_to_le32(pci_map_single(streamer_priv->pci_dev, &streamer_priv->streamer_rx_ring[0],
drivers/net/tokenring/lanstreamer.c:    writel(cpu_to_le32(pci_map_single(streamer_priv->pci_dev, &streamer_priv->streamer_rx_ring[STREAMER_RX_RING_SIZE - 1],
drivers/net/tokenring/lanstreamer.c:                                    writel(cpu_to_le32(pci_map_single(streamer_priv->pci_dev, 
drivers/net/tokenring/lanstreamer.c:                                            writel(cpu_to_le32(pci_map_single(streamer_priv->pci_dev, 
drivers/net/tokenring/lanstreamer.c:            writel(cpu_to_le32(pci_map_single(streamer_priv->pci_dev, 
drivers/net/via-velocity.c:             writel(cpu_to_le32(vptr->rd_pool_dma), &regs->RDBaseLo);
drivers/net/via-velocity.c:                     writel(cpu_to_le32(vptr->td_pool_dma[i]), &(regs->TDBaseLo[i]));
drivers/scsi/nsp32_io.h:        writew(cpu_to_le16(val), ptr);
drivers/scsi/nsp32_io.h:        writel(cpu_to_le32(val), ptr);
drivers/scsi/nsp32_io.h:        writew(cpu_to_le16(val), data_ptr );
drivers/block/umem.c:   writel(cpu_to_le32((page->page_dma+offset)&0xffffffff),
drivers/block/umem.c:   writel(cpu_to_le32(((u64)page->page_dma)>>32),
drivers/block/umem.c:   writel(cpu_to_le32(DMASCR_GO | DMASCR_CHAIN_EN | pci_cmds),
drivers/block/umem.c:           writel(cpu_to_le32(DMASCR_DMA_COMPLETE|DMASCR_CHAIN_COMPLETE),

-- 
Greetings Michael.
