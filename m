From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/tg3: Release IRQs on permanent error
Date: Sat, 25 Apr 2015 14:42:12 -0400 (EDT)
Message-ID: <20150425.144212.306837701165179931.davem@davemloft.net>
References: <1429852943-28953-1-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, prashant@broadcom.com, mchan@broadcom.com
To: gwshan@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35264 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbbDYSmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 14:42:16 -0400
In-Reply-To: <1429852943-28953-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Date: Fri, 24 Apr 2015 15:22:23 +1000

> When having permanent EEH error, the PCI device will be removed
> from the system. For this case, we shouldn't set pcierr_recovery
> to true wrongly, which blocks the driver to release the allocated
> interrupts and their handlers. Eventually, we can't disable MSI
> or MSIx successfully because of the MSI or MSIx interrupts still
> have associated interrupt actions, which is turned into following
> stack dump.
> 
> Oops: Exception in kernel mode, sig: 5 [#1]
>         :
> [c0000000003b76a8] .free_msi_irqs+0x80/0x1a0 (unreliable)
> [c00000000039f388] .pci_remove_bus_device+0x98/0x110
> [c0000000000790f4] .pcibios_remove_pci_devices+0x9c/0x128
> [c000000000077b98] .handle_eeh_events+0x2d8/0x4b0
> [c0000000000782d0] .eeh_event_handler+0x130/0x1c0
> [c000000000022bd4] .kernel_thread+0x54/0x70
> 
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>

Applied.
