From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/2] ixgbe: fix for 82598 Si errata causing
 buffer overflow
Date: Sat, 21 Feb 2009 15:43:05 -0800 (PST)
Message-ID: <20090221.154305.237729082.davem@davemloft.net>
References: <20090221222318.6451.16633.stgit@lost.foo-projects.org>
	<20090221222339.6451.72721.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57842
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754533AbZBUXnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 18:43:23 -0500
In-Reply-To: <20090221222339.6451.72721.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 21 Feb 2009 14:23:40 -0800

> The failure happens when an interrupt occurs and the driver is reading
> EICR.  This read will cause a clear-by-read which leads to two TLP
> being inserted in the PCIe retry buffer leading to an overflow of the
> buffer and corruption of TLPs.
> 
> The solution is different depending where the reading of EICR takes place.
> 
> For ixgbe_msix_lsc() since we are in MSIX mode and know OCD is enabled a
> clear-by-write is done instead of the normal clear-by-read.
> 
> For ixgbe_intr() 0xffffffff is written to EIMC before the read, masking the
> interrupts.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
