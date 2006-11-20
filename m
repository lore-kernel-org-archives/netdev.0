From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 3/3] NetXen: 64-bit memory fixes, driver cleanup
Date: Mon, 20 Nov 2006 10:45:53 -0800
Message-ID: <20061120104553.434b6ec5@freekitty>
References: <200611171536.kAHFa3os005563@dut39.unminc.com>
	<20061117084049.555e14d0@localhost.localdomain>
	<1163845689.4822.6.camel@nbsanjeev>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linsys Contractor Amit S. Kale" <amitkale@netxen.com>,
	netdev <netdev@vger.kernel.org>,
	brazilnut <brazilnut@us.ibm.com>, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com,
	wendyx <wendyx@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:44959 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S966379AbWKTSuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 13:50:25 -0500
To: sanjeev@netxen.com
In-Reply-To: <1163845689.4822.6.camel@nbsanjeev>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 18 Nov 2006 15:58:09 +0530
Sanjeev Jorapur <sanjeev@netxen.com> wrote:

> On Fri, 2006-11-17 at 08:40 -0800, Stephen Hemminger wrote:
> > On Fri, 17 Nov 2006 07:36:03 -0800
> > "Linsys Contractor Amit S. Kale" <amitkale@netxen.com> wrote:
> > 
> > > NetXen: 1G/10G Ethernet Driver updates
> > > 	- These fixes take care of driver on machines with >4G memory
> > > 	- Driver cleanup
> > > 
> > > Signed-off-by: Amit S. Kale <amitkale@netxen.com>
> > > 
> > >  netxen_nic.h          |   41 ++++++----
> > >  netxen_nic_ethtool.c  |   19 ++--
> > >  netxen_nic_hw.c       |   10 +-
> > >  netxen_nic_hw.h       |    4 
> > >  netxen_nic_init.c     |   51 +++++++++++-
> > >  netxen_nic_isr.c      |    3 
> > >  netxen_nic_main.c     |  204 +++++++++++++++++++++++++++++++++++++++++++++++---
> > >  netxen_nic_phan_reg.h |   10 +-
> > >  8 files changed, 293 insertions(+), 49 deletions(-)
> > > 
> > 
> > 
> > If you can't DMA from high memory, then don't set NETIF_F_HIGHDMA, why do
> > you need explicit bounce buffers.  If you can't DMA from unaligned address,
> > the write a small routine to copy the skb to a new one.
> 
> 
> The hardware supports DMA into 35 bit addresses. The intent is to
> enable DMA into addresses upto 32G.
> 

You should then set the same value for pci_set_dma_mask, because then the IOMMU
can help. See both b44 or tg3 drivers, they have to deal with odd size masks.
I don't think you have to do all the bounce buffer work in the driver.

-- 
Stephen Hemminger <shemminger@osdl.org>
