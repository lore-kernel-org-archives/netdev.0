From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 06/17] sky2: advanced error reporting
Date: Wed, 9 May 2007 15:35:32 -0700
Message-ID: <20070509153532.68adcb46@localhost>
References: <20070509034949.624934448@linux-foundation.org>
	<20070509035028.970057572@linux-foundation.org>
	<20070509170551.GW4452@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Greg KH <greg@kroah.com>, linux-pci@atrey.karlin.mff.cuni.cz
To: linas@austin.ibm.com (Linas Vepstas)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:53851 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759395AbXEIWfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 18:35:52 -0400
In-Reply-To: <20070509170551.GW4452@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 May 2007 12:05:51 -0500
linas@austin.ibm.com (Linas Vepstas) wrote:

> On Tue, May 08, 2007 at 08:49:55PM -0700, Stephen Hemminger wrote:
> > Use the kernel interfaces for advanced error reporting.
> > This should be cleaner and clear up errors on boot.
> 
> Hmm. I thought that the AER functions would eventually 
> be handled by the struct pci_error_handlers callbacks,
> so that dev drivers wouldn't actually have code such as

No, it doesn't seem to work that way. Those callback seems to
be for bus reported errors, not device reported errors.


> > +		pci_read_config_dword(pdev, pos + PCI_ERR_UNCOR_STATUS, &status);
> > +		pci_read_config_dword(pdev, pos + PCI_ERR_UNCOR_SEVER, &mask);
> 
> in them. But perhaps I haven't studed what this drivr is trying to 
> do; nor have I really kept track of the aer code.
> 

On boot up it clears errors because power on seems to leave a bogus
error report.

When error is detected, it gets an IRQ and than has to decode it as PCI
error.

Earlier versions of the driver (pre AER) were doing the same thing but
with only minimal handling of errors. Now at least it uses common code.
