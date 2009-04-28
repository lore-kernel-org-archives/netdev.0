From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] ixgbe: enable HW RSC for 82599
Date: Tue, 28 Apr 2009 01:55:35 -0700 (PDT)
Message-ID: <20090428.015535.42660210.davem@davemloft.net>
References: <20090428084236.32710.14750.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37629
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755498AbZD1Izm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:55:42 -0400
In-Reply-To: <20090428084236.32710.14750.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 28 Apr 2009 01:42:37 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch enables hardware receive side coalescing for 82599 hardware.
> 82599 can merge multiple frames from the same TCP/IP flow into a single
> structure that can span one ore more descriptors.  The accumulated data is
> arranged similar to how jumbo frames are arranged with the exception that
> other packets can be interlaced inbetween.  To overcome this issue a next
> pointer is included in the written back descriptor which indicates the next
> descriptor in the writeback sequence.
> 
> This feature sets the NETIF_F_LRO flag and clearing it via the ethtool set
> flags operation will also disable hardware RSC.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, but.........

Since IXGBE has been converted to GRO, all of this fiddling with
LRO is a complete NOP.  All of that code can be removed completely.
