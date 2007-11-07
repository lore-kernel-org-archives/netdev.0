From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] PCI: export pci_restore_msi_state()
Date: Wed, 7 Nov 2007 16:07:10 -0600
Message-ID: <20071107220710.GK4239@austin.ibm.com>
References: <20071107214359.GJ4239@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	mcarlson@broadcom.com, wenxiong@us.ibm.com, mchan@broadcom.com,
	"Kok, Auke" <auke-jan.h.kok@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:33932 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759710AbXKGWHP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 17:07:15 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA7M8lKM032232
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 17:08:47 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA7M7BOJ490774
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 17:07:11 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA7M7A88003105
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 17:07:11 -0500
Content-Disposition: inline
In-Reply-To: <20071107214359.GJ4239@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Nov 07, 2007 at 03:43:59PM -0600, Linas Vepstas wrote:
> 
> PCI error recovery usually involves the PCI adapter being reset.
> If the device is using MSI, the reset will cause the MSI state 
> to be lost; the device driver needs to restore the MSI state.
> 
> The pci_restore_msi_state() routine is currently protected
> by CONFIG_PM; remove this, and also export the symbol, so
> that it can be used in a modle.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

The long time delay has managed to muddle notes & recollection 
of prior discussions. This patch should have had a 

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

on it; its the same patch that was submitted a long time ago.

During the discussions of 21 Oct, it was proposed that there
should be an arch hook for pci_restore_msi_state(), so that
it would be treated at the same level as msi setup and teardown.
I'd volunteered to write that patch. 

When I sat down to do it, however, I realized that I did not
actually *need* it. And so I wondered: why am I writing un-needed,
but theoretically proper, code? So I punted, and I didn't.
Does that make sense?

That's also why this patch is just a resubmission of the old
patch. The original thread is here:

http://www.mail-archive.com/netdev@vger.kernel.org/msg51296.html

--linas



