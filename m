From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/CXGB3: Avoid access MMIO on offlined PCI dev
Date: Sat, 27 Jul 2013 20:14:21 -0700 (PDT)
Message-ID: <20130727.201421.864510110128224403.davem@davemloft.net>
References: <1374737524-8410-1-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com
To: shangw@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978Ab3G1DOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jul 2013 23:14:22 -0400
In-Reply-To: <1374737524-8410-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <shangw@linux.vnet.ibm.com>
Date: Thu, 25 Jul 2013 15:32:04 +0800

> While we have EEH errors happened on specific PCI device, the PE
> (Partitionable Endpoint) which includes the PCI device is expected
> to be reset. During the reset, the PCI device should have been
> marked as "offline" and it's not safe to access MMIO of that PCI
> device with "offline" state. That might cause the failure to do
> EEH recovery and then the PCI device is removed from the system for
> ever before manual recovery.
> 
> The patch avoids access to MMIO while the PCI device has been marked
> "offline" so that to avoid additional EEH errors during reset and make
> sure that the EEH recovery can be done successfully.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>

Making this check on every single register read or write is not
reasonable.

If this is how register access in every driver has to be done in order
to support EEH errors properly, it is simply not acceptable.
