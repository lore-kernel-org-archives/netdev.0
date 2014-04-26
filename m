From: David Miller <davem@davemloft.net>
Subject: Re: [net] i40e: fix Timesync Tx interrupt handler code
Date: Sat, 26 Apr 2014 12:56:14 -0400 (EDT)
Message-ID: <20140426.125614.583874864644445070.davem@davemloft.net>
References: <1398387903-30502-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacob.e.keller@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52675 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbaDZQ4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 12:56:15 -0400
In-Reply-To: <1398387903-30502-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 24 Apr 2014 18:05:03 -0700

> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> This patch fixes the PTP Tx timestamp interrupt handler. The original
> code misinterpreted the interrupt handler design. We were clearing the
> ena_mask bit for the Timesync interrupts. This is done to indicate that
> the interrupt will be handled in a scheduled work item (instead of
> immediately) and that work item is responsible for re-enabling the
> interrupts. However, the Tx timestamp was being handled immediately and
> nothing was ever re-enabling it. This resulted in a single interrupt
> working for the life of the driver.
> 
> This patch fixes the issue by instead clearing the bit from icr0 which
> is used to indicate that the interrupt was immediately handled and can
> be re-enabled right away. This patch also clears up a related issue due
> to writing the PRTTSYN_STAT_0 register, which was unintentionally
> clearing the cause bits for Timesync interrupts.
> 
> Change-ID: I057bd70d53c302f60fab78246989cbdfa469d83b
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Acked-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Acked-by: Shannon Nelson <shannon.nelson@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks everyone.
