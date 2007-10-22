From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Mon, 22 Oct 2007 13:07:24 -0500
Message-ID: <20071022180724.GB4280@austin.ibm.com>
References: <1192829817.22064.559.camel@teletran1> <20071021.162131.43417026.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:36584 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751408AbXJVSH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 14:07:26 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9MI7QSR008801
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 14:07:26 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MI7Pkw118880
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 14:07:25 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MI7P48027221
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 14:07:25 -0400
Content-Disposition: inline
In-Reply-To: <20071021.162131.43417026.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 21, 2007 at 04:21:31PM -0700, David Miller wrote:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Fri, 19 Oct 2007 14:36:56 -0700
> 
> > This patch exports the pci_restore_msi_state() function.  This function
> > is needed to restore the MSI state during PCI error recovery.
> > 
> > Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> I'm not so sure about this.
> 
> Perhaps, instead, you should do a pci_msi_disable() and
> pci_msi_enable() in the error detection and recovery sequence.
> 
> Or, alternatively, save/restore those MSI registers by hand.
> 
> I'm trying to figure out how the E1000 driver handles this correctly,
> but I can't see it just by reading it over quickly.

The e1000 and the ixgb are broken as well ... right now, any
driver that uses msi together with the pci error recovery will
fail to get recovered correctly.  There are several distinct bugs;
one is that, msi state is not being restored; and the call to 
pci_restore_msi_state() was supposed to aid with that.

I'd rather not use pci_msi_disable(), because that has the 
side-effect of enabling legacy interupts; I'm concerned that 
this will have the potential for causing havoc of all sorts.

--linas
