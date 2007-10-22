From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state()
 function
Date: Sun, 21 Oct 2007 21:01:17 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AABB04@nt-irva-0751.brcm.ad.broadcom.com>
References: <20071021.162131.43417026.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz,
	linas@austin.ibm.com
To: "David Miller" <davem@davemloft.net>,
	"Matthew Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1577 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750714AbXJVEB5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 00:01:57 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20071021.162131.43417026.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> I'm not so sure about this.
> 
> Perhaps, instead, you should do a pci_msi_disable() and
> pci_msi_enable() in the error detection and recovery sequence.

If we just detected PCI errors on this slot, I don't think it's
a good idea to continue writing to the config space to disable
MSI.  Perhaps we can disable/enable after the slot reset.

> 
> Or, alternatively, save/restore those MSI registers by hand.

We can do that, but we'll have to do it ahead of time when we enable
MSI, not after errors have been detected.  But the address/data can
change as the CPU affinity changes during run time, right?

