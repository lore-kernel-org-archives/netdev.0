From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Fri, 19 Oct 2007 17:27:06 -0700 (PDT)
Message-ID: <20071019.172706.57467960.davem@davemloft.net>
References: <20071019232926.GL29903@austin.ibm.com>
	<1192840577.5369.9.camel@dell>
	<20071020000421.GO29903@austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, mcarlson@broadcom.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58210
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758773AbXJTA04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 20:26:56 -0400
In-Reply-To: <20071020000421.GO29903@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: linas@austin.ibm.com (Linas Vepstas)
Date: Fri, 19 Oct 2007 19:04:21 -0500

> I'm working in linux-2.6.23-rc8-mm1 at the moment, and I don't see
> that happening. viz. read_msi_msg() is not called anywhere, and I need
> to have valid msg->address_lo and msg->address_hi and msg->data
> in order to be able to restore.

The generic PCI layer will save away the PCI config space elements
during pci_enable_msi(), including the MSI address and data values.

You can fetch the values you need from there during restore if
you need them.

See the pci_restore_msi_state() call done from pci_restore_state()
in drivers/pci/pci.c, that pci_restore_msi_state() code in
drivers/pci/msi.c very much relies upon the entry->msg values
being uptodate and valid.

The MSI arch layer code is supposed to fill the entry->msg values in
via arch_setup_msi_irq().  Perhaps the pseries code is forgetting to
do that.

So I can't really see what the problem is you're talking about.
