From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH 7/8] NetXen: Fix for PPC machines.
Date: Wed, 27 Dec 2006 08:06:33 +0000
Message-ID: <20061227080633.GN17561@ftp.linux.org.uk>
References: <200612181353.kBIDrx7D012229@dut39.unminc.com> <20061227075854.GA32567@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org,
	brazilnut@us.ibm.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:56341 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932964AbWL0IGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 03:06:39 -0500
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20061227075854.GA32567@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 27, 2006 at 07:58:54AM +0000, Christoph Hellwig wrote:
> On Mon, Dec 18, 2006 at 05:53:59AM -0800, Amit S. Kale wrote:
> > Signed-off-by: Amit S. Kale <amitkale@netxen.com> 
> >  
> >  netxen_nic.h      |    2 +-
> >  netxen_nic_init.c |   12 ++++++------
> >  netxen_nic_main.c |    4 ++--
> >  3 files changed, 9 insertions(+), 9 deletions(-)
> 
> Please use __le* types for all hardware data structures and use sparse
> to verify all your endianess handling is correct.

I have preliminary endianness annotations for that puppy; FWIW, a part of
it consists of _removing_ __le.  Folks, readl() returns host-endian and
writel() takes host-endian as argument.  They do conversions themselves.
One needs fixed-endian types in data structures shared with device - i.e.
anything in ioremapped area or dma'd to/from device.
