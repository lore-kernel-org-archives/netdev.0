From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: Re: [PATCH 1/7] NetXen: Use multiple PCI functions
Date: Thu, 19 Apr 2007 20:30:21 +0530
Message-ID: <200704192030.21745.mithlesh@netxen.com>
References: <200704191452.l3JEqOYv032290@dut39.unminc.com> <20070419080059.1fe5d937@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:25626 "EHLO
	svr68.ehostpros.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1766791AbXDSPHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 11:07:07 -0400
In-Reply-To: <20070419080059.1fe5d937@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 19 April 2007 20:30, Stephen Hemminger wrote:
> On Thu, 19 Apr 2007 07:52:24 -0700
>
> Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com> wrote:
> > NetXen: Make driver use multiple PCI functions.
> > This patch will make NetXen driver work with multiple PCI functions. This
> > will make the usage of memory resources as well as interrupts more
> > independent among different functions which results in better throughput.
> > This change has been done after the multiport support is added in
> > firmware.
> >
> > Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> >
> > ---
> >
> >  drivers/net/netxen/netxen_nic.h          |  126 ++---
> >  drivers/net/netxen/netxen_nic_ethtool.c  |   83 +--
> >  drivers/net/netxen/netxen_nic_hdr.h      |    8
> >  drivers/net/netxen/netxen_nic_hw.c       |  217 ++++++--
> >  drivers/net/netxen/netxen_nic_hw.h       |   18
> >  drivers/net/netxen/netxen_nic_init.c     |  117 +---
> >  drivers/net/netxen/netxen_nic_isr.c      |   87 +--
> >  drivers/net/netxen/netxen_nic_main.c     |  526 ++++++++++-----------
> >  drivers/net/netxen/netxen_nic_niu.c      |   27 -
> >  drivers/net/netxen/netxen_nic_phan_reg.h |  125 ----
> >  10 files changed, 645 insertions(+), 689 deletions(-)
> >
> > diff --git a/drivers/net/netxen/netxen_nic.h
> > b/drivers/net/netxen/netxen_nic.h index dd8ce35..7a5a95e 100644
> > --- a/drivers/net/netxen/netxen_nic.h
> > +++ b/drivers/net/netxen/netxen_nic.h
> > @@ -219,6 +219,7 @@ #define MIN_RX_COUNT	4096
> >  #define NETXEN_CTX_SIGNATURE	0xdee0
> >  #define NETXEN_RCV_PRODUCER(ringid)	(ringid)
> >  #define MAX_FRAME_SIZE	0x10000	/* 64K MAX size for LSO */
> > +#define MAC_ADDR_LEN 	6
>
> Please use ETH_ALEN for this if it is an ethernet device.
Ok. I will change this as it for an ethernet device. Will wait for some other 
feedback, otherwise send the updated patchset tomorrow.

Thanks,
Mithlesh Thukral
