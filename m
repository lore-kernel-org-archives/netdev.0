From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] PCI: export pci_restore_msi_state()
Date: Fri, 9 Nov 2007 10:42:39 -0600
Message-ID: <20071109164239.GK4239@austin.ibm.com>
References: <20071107214359.GJ4239@austin.ibm.com> <OFD31717CC.A38DF9AF-ON8725738E.00069FB3-8625738E.00077F2A@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-pci@atrey.karlin.mff.cuni.cz, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org
To: Wen Xiong <wenxiong@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:44241 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753832AbXKIQnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 11:43:05 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA9Ggurn014738
	for <netdev@vger.kernel.org>; Fri, 9 Nov 2007 11:42:56 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA9GgoxS043580
	for <netdev@vger.kernel.org>; Fri, 9 Nov 2007 09:42:53 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA9GgmHC026616
	for <netdev@vger.kernel.org>; Fri, 9 Nov 2007 09:42:50 -0700
Content-Disposition: inline
In-Reply-To: <OFD31717CC.A38DF9AF-ON8725738E.00069FB3-8625738E.00077F2A@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 08, 2007 at 07:21:01PM -0600, Wen Xiong wrote:
> Hi Linas,
> 
> I saw you have submitted several patches to support pci-express network 
> adapters EEH. But looks only this patch fixed something in linux kernel 
> code.

And its an old patch, submitted long ago ... I've resubmitted, because
it seems that its the best/most correct thing to do.

> Do you mean I can test EEH callback functions in device driver after I 
> apply  this patch in the kernel?

Yes, please.  Note, however, I was never able to make the pci-e 
version of the e1000 work. It comes up, generates interrupts, and
registeres are readable and writeable. But it behvaes as if the PHY 
is turned off -- no network traffic goes thorugh. (I tried turning
PHY on explicitly; that didn't help). So there is still something 
wrong somewhere, probably in the e1000 deice driver. I'm guessing
the pci-e to pci-x bridge chip on that card is not quite resetting
the card completely.

> Do you do "pci_save_msi_state" somewhere in the kernel? Or you suggest to 
> do "pci_save_msi_state" and "pci_restore_msi_state" in each device driver?

There is no "save state", the msi state can't be saved. The MSI regs
are write-only, and they are controlled by firmware. The restore_state
function is the only one you need.

--linas
