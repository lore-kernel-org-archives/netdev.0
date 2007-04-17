From: Amit Kale <amitkale@netxen.com>
Subject: Re: [PATCH 3/7] NetXen: Multi PCI support for Quad cards
Date: Tue, 17 Apr 2007 22:10:08 +0530
Message-ID: <200704172210.09048.amitkale@netxen.com>
References: <200704131539.l3DFdVen002569@dut39.unminc.com> <20070416104924.07ad9919@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>,
	netdev@vger.kernel.org, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:18516 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030795AbXDQQjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 12:39:33 -0400
In-Reply-To: <20070416104924.07ad9919@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 16 April 2007 23:19, Stephen Hemminger wrote:
> On Fri, 13 Apr 2007 08:39:31 -0700
>
> Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com> wrote:
> > NetXen: Fix the multi PCI function for cards with more than 2 ports.
> > This patch fixes the working of multi PCI capable driver on cards with
> > more than 2 ports by adding the addresses for their rings and sizes.
> >
> > Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> >
> > ---
> >
> >  drivers/net/netxen/netxen_nic_hw.c       |  119 +++++++++++++++++++--
> >  drivers/net/netxen/netxen_nic_init.c     |    4
> >  drivers/net/netxen/netxen_nic_main.c     |   61 +++++-----
> >  drivers/net/netxen/netxen_nic_phan_reg.h |    6 -
> >  4 files changed, 146 insertions(+), 44 deletions(-)
> >
> > diff --git a/drivers/net/netxen/netxen_nic_hw.c
> > b/drivers/net/netxen/netxen_nic_hw.c index a066208..274a261 100644
> > --- a/drivers/net/netxen/netxen_nic_hw.c
> > +++ b/drivers/net/netxen/netxen_nic_hw.c
> > @@ -140,8 +140,105 @@ struct netxen_recv_crb recv_crb_register
> >  	 NETXEN_NIC_REG(0x180),
> >  	 /* crb_status_ring_size */
> >  	 NETXEN_NIC_REG(0x184),
> > -
> >  	 },
> > +	/*
> > +	 * Instance 3,
> > +	 */
> > +	{
> > +	  {
> > +	    {
> > +	    /* crb_rcv_producer_offset: */
> > +	    NETXEN_NIC_REG(0x1d8),
> > +	    /* crb_rcv_consumer_offset: */
> > +	    NETXEN_NIC_REG(0x1dc),
> > +	    /* crb_gloablrcv_ring: */
> > +	    NETXEN_NIC_REG(0x1f0),
> > +	    /* crb_rcv_ring_size */
> > +	    NETXEN_NIC_REG(0x1f4),
> > +	    },
> > +	    /* Jumbo frames */
> > +	    {
> > +	    /* crb_rcv_producer_offset: */
> > +	    NETXEN_NIC_REG(0x1f8),
> > +	    /* crb_rcv_consumer_offset: */
> > +	    NETXEN_NIC_REG(0x1fc),
> > +	    /* crb_gloablrcv_ring: */
> > +	    NETXEN_NIC_REG(0x200),
> > +	    /* crb_rcv_ring_size */
> > +	    NETXEN_NIC_REG(0x204),
> > +	    },
> > +	    /* LRO */
> > +	    {
> > +	    /* crb_rcv_producer_offset: */
> > +	    NETXEN_NIC_REG(0x208),
> > +	    /* crb_rcv_consumer_offset: */
> > +	    NETXEN_NIC_REG(0x20c),
> > +	    /* crb_gloablrcv_ring: */
> > +	    NETXEN_NIC_REG(0x210),
> > +	    /* crb_rcv_ring_size */
> > +	    NETXEN_NIC_REG(0x214),
> > +	    }
> > +	  },
> > +	  /* crb_rcvstatus_ring: */
> > +	  NETXEN_NIC_REG(0x218),
> > +	  /* crb_rcv_status_producer: */
> > +	  NETXEN_NIC_REG(0x21c),
> > +	  /* crb_rcv_status_consumer: */
> > +	  NETXEN_NIC_REG(0x220),
> > +	  /* crb_rcvpeg_state: */
> > +	  NETXEN_NIC_REG(0x224),
> > +	  /* crb_status_ring_size */
> > +	  NETXEN_NIC_REG(0x228),
> > +	},
> > +	/*
> > +	 * Instance 4,
> > +	 */
> > +	{
> > +	  {
> > +	    {
> > +	    /* crb_rcv_producer_offset: */
> > +	    NETXEN_NIC_REG(0x22c),
> > +	    /* crb_rcv_consumer_offset: */
> > +	    NETXEN_NIC_REG(0x230),
> > +	    /* crb_gloablrcv_ring: */
> > +	    NETXEN_NIC_REG(0x234),
> > +	    /* crb_rcv_ring_size */
> > +	    NETXEN_NIC_REG(0x238),
> > +	    },
> > +	    /* Jumbo frames */
> > +	    {
> > +	    /* crb_rcv_producer_offset: */
> > +	    NETXEN_NIC_REG(0x23c),
> > +	    /* crb_rcv_consumer_offset: */
> > +	    NETXEN_NIC_REG(0x240),
> > +	    /* crb_gloablrcv_ring: */
> > +	    NETXEN_NIC_REG(0x244),
> > +	    /* crb_rcv_ring_size */
> > +	    NETXEN_NIC_REG(0x248),
> > +	    },
> > +	    /* LRO */
> > +	    {
> > +	    /* crb_rcv_producer_offset: */
> > +	    NETXEN_NIC_REG(0x24c),
> > +	    /* crb_rcv_consumer_offset: */
> > +	    NETXEN_NIC_REG(0x250),
> > +	    /* crb_gloablrcv_ring: */
> > +	    NETXEN_NIC_REG(0x254),
> > +	    /* crb_rcv_ring_size */
> > +	    NETXEN_NIC_REG(0x258),
> > +	    }
> > +	  },
> > +	  /* crb_rcvstatus_ring: */
> > +	  NETXEN_NIC_REG(0x25c),
> > +	  /* crb_rcv_status_producer: */
> > +	  NETXEN_NIC_REG(0x260),
> > +	  /* crb_rcv_status_consumer: */
> > +	  NETXEN_NIC_REG(0x264),
> > +	  /* crb_rcvpeg_state: */
> > +	  NETXEN_NIC_REG(0x268),
> > +	  /* crb_status_ring_size */
> > +	  NETXEN_NIC_REG(0x26c),
> > +	},
> >  };
> >
> >  u64 ctx_addr_sig_regs[][3] = {
> > @@ -294,6 +391,7 @@ int netxen_nic_hw_resources(struct netxe
> >  	u32 card_cmdring = 0;
> >  	struct netxen_recv_context *recv_ctx;
> >  	struct netxen_rcv_desc_ctx *rcv_desc;
> > +	int func_id = adapter->portnum;
> >
> >  	DPRINTK(INFO, "crb_base: %lx %x", NETXEN_PCI_CRBSPACE,
> >  		PCI_OFFSET_SECOND_RANGE(adapter, NETXEN_PCI_CRBSPACE));
> > @@ -341,7 +439,7 @@ int netxen_nic_hw_resources(struct netxe
> >  			    &adapter->ctx_desc_pdev);
> >
> >  	printk(KERN_INFO "ctx_desc_phys_addr: 0x%llx\n",
> > -	       (unsigned long long) adapter->ctx_desc_phys_addr);
> > +	       (u64) adapter->ctx_desc_phys_addr);
>
> This will give a warning on 64 bit platforms because format doesn't match
> width. You need to cast to (unsigned long long).

OOPS! We'll do this change.
Thanks.
-Amit
