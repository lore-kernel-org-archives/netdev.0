From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [BUG] powerpc does not save msi state [was Re: [PATCH 5/7]
	pci: Export the pci_restore_msi_state() function
Date: Tue, 23 Oct 2007 10:32:15 +1000
Message-ID: <1193099535.6745.172.camel@pasglop>
References: <20071020004610.GR29903@austin.ibm.com>
	 <20071019.175308.54212640.davem@davemloft.net>
	 <20071022195451.GE4280@austin.ibm.com>
	 <20071022.172332.112621497.davem@davemloft.net>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linas@austin.ibm.com, netdev@vger.kernel.org,
	mcarlson@broadcom.com, linuxppc-dev@ozlabs.org, mchan@broadcom.com,
	linux-pci@atrey.karlin.mff.cuni.cz
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57889 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751028AbXJWAcd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 20:32:33 -0400
In-Reply-To: <20071022.172332.112621497.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 2007-10-22 at 17:23 -0700, David Miller wrote:
> From: linas@austin.ibm.com (Linas Vepstas)
> Date: Mon, 22 Oct 2007 14:54:52 -0500
> 
> > As discussed in the other thread, I'll try to set up a patch
> > for an arch callback for restoring msi state.

>From what it looks like at this stage, pSeries might need to
differenciate restoring MSI state after a device reset (PCI error
recovery) from restoring MSI state after suspend/resume (if we ever
implement that one).

The former apparently require manual saving & restoring of the config
space bits. (Linas, do you have a pointer to the bit of PAPR spec that
specifies that we need to save & restore the MSI message ourselves ?)

For the later (suspend/resume), that will definitely not work, or at
least, will not be enough, especially with something like suspend to
disk, where we'll need to have the firmware reconfigure the MSIs for us
(to make sure, among others, that the interrupt controllers are properly
configured for MSIs etc...).

Ben.


