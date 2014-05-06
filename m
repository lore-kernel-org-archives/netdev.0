From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH v8 1/1] Driver for Beckhoff CX5020 EtherCAT master
 module.
Date: Tue, 6 May 2014 17:12:35 +0200
Message-ID: <20140506151235.GI6455@distanz.ch>
References: <20140505191045.GK1156@newterm.pl>
 <20140506145606.GH6455@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Darek Marcinkiewicz <reksio@newterm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:55885 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752527AbaEFPMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 11:12:36 -0400
Content-Disposition: inline
In-Reply-To: <20140506145606.GH6455@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-05-06 at 16:56:06 +0200, Tobias Klauser <tklauser@distanz.ch> wrote:
> On 2014-05-05 at 21:10:45 +0200, Darek Marcinkiewicz <reksio@newterm.pl> wrote:
> > 
> > This driver adds support for EtherCAT master module located on CCAT
> > FPGA found on Beckhoff CX series industrial PCs. The driver exposes
> > EtherCAT master as an ethernet interface.
> > 
> > EtherCAT is a fieldbus protocol defined on top of ethernet and Beckhoff
> > CX5020 PCs come with built-in EtherCAT master module located on a FPGA,
> > which in turn is connected to a PCI bus.
> > 
> > Signed-off-by: Dariusz Marcinkiewicz <reksio@newterm.pl>
> > ---
> > 
> > Changes from v7:
> >   * added 'depends on PCI' to the driver's Kconfig entry
> > 
> > Changes from v6:
> >   * added memory barriers to avoid race between timer handler and xmit routine 
> >   * includes formatting/indeting changes from Francois Romieu
> > 
> > Changes from v5:
> >   * removal of needless locking on tx path
> >   * driver makes actual use of tx fifo
> >   * driver uses descriptors' array instead of descriptor list
> > 
> > Changes from v4: 
> >   * incorporates Francois Romieu comments
> >   * fixes typo spotted by Jesper Brouer
> > 
> > Changes from v3:
> >   * some clarificatoins around buffer allocations
> > 
> > Changes from v2:
> >   * removed all checkpatch warnings
> >   * driver makes use of device rx fifo
> > 
> > Changes from v1:
> >   * added endianess annotation to descriptors' structures
> >   * killed checkpath warnings about string literals being split into multiple
> >     lines
> > 
> >  drivers/net/ethernet/Kconfig  |   12 +
> >  drivers/net/ethernet/Makefile |    1 +
> >  drivers/net/ethernet/ec_bhf.c |  705 +++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 718 insertions(+)
> >  create mode 100644 drivers/net/ethernet/ec_bhf.c
> 
> [...]
> 
> > +struct ec_bhf_priv {
> > +	struct net_device *net_dev;
> > +
> > +	struct pci_dev *dev;
> > +
> > +	void * __iomem io;
> > +	void * __iomem dma_io;
> > +
> > +	struct hrtimer hrtimer;
> > +
> > +	int tx_dma_chan;
> > +	int rx_dma_chan;
> > +	void * __iomem ec_io;
> > +	void * __iomem fifo_io;
> > +	void * __iomem mii_io;
> > +	void * __iomem mac_io;
> > +
> > +	struct bhf_dma rx_buf;
> > +	struct rx_desc *rx_descs;
> > +	int rx_dnext;
> > +	int rx_dcount;
> > +
> > +	struct bhf_dma tx_buf;
> > +	struct tx_desc *tx_descs;
> > +	int tx_dcount;
> > +	int tx_dnext;
> > +
> > +	u64 stat_rx_bytes;
> > +	u64 stat_tx_bytes;
> 
> netdev->stats already provides {rx,tx}_bytes members, so you can get rid
> of these two.

Actually, no. The net_device_stats members are unsigned long, so your
solution is fine. Please disregard.
