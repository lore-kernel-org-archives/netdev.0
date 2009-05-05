From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000: fix virtualization bug
Date: Mon, 04 May 2009 21:31:04 -0700 (PDT)
Message-ID: <20090504.213104.13037490.davem@davemloft.net>
References: <20090504211941.10922.95964.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55974
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750891AbZEEEbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 00:31:10 -0400
In-Reply-To: <20090504211941.10922.95964.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 04 May 2009 14:19:42 -0700

> a recent fix to e1000 (commit 15b2bee2) caused KVM/QEMU/VMware based
> virtualized e1000 interfaces to begin failing when resetting.
> 
> This is because the driver in a virtual environment doesn't
> get to run instructions *AT ALL* when an interrupt is asserted.
> The interrupt code runs immediately and this recent bug fix
> allows an interrupt to be possible when the interrupt handler
> will reject it (due to the new code), when being called from
> any path in the driver that holds the E1000_RESETTING flag.
> 
> the driver should use the __E1000_DOWN flag instead of the
> __E1000_RESETTING flag to prevent interrupt execution
> while reconfiguring the hardware.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
