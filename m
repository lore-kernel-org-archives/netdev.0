From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [net-next PATCH 1/3] ixgbe: enable HW RSC for 82599
Date: Tue, 28 Apr 2009 17:12:10 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0904281648300.5352@jbrandeb-desk1.amr.corp.intel.com>
References: <20090428084236.32710.14750.stgit@localhost.localdomain> <20090428.015535.42660210.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:10168 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752346AbZD2AMM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 20:12:12 -0400
In-Reply-To: <20090428.015535.42660210.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Apr 2009, David Miller wrote:
> > This patch enables hardware receive side coalescing for 82599 hardware.
> > 82599 can merge multiple frames from the same TCP/IP flow into a single
> > structure that can span one ore more descriptors.  The accumulated data is
> > arranged similar to how jumbo frames are arranged with the exception that
> > other packets can be interlaced inbetween.  To overcome this issue a next
> > pointer is included in the written back descriptor which indicates the next
> > descriptor in the writeback sequence.
> > 
> > This feature sets the NETIF_F_LRO flag and clearing it via the ethtool set
> > flags operation will also disable hardware RSC.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Applied, but.........
> 
> Since IXGBE has been converted to GRO, all of this fiddling with
> LRO is a complete NOP.  All of that code can be removed completely.

ah, you're right, but this features enables our new hardware that can do 
LRO in hardware, and then GRO can work on top of it if necessary.  We 
wanted some way to turn it off and overloaded the LRO flag to do so.

FYI This is not a TOE, it just recognizes a flow and will pack data frames 
together in a list of descriptors, which the driver then hands to the 
stack as a large receive.
