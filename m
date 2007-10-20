From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Fri, 19 Oct 2007 19:04:21 -0500
Message-ID: <20071020000421.GO29903@austin.ibm.com>
References: <1192829817.22064.559.camel@teletran1> <20071019232926.GL29903@austin.ibm.com> <1192840577.5369.9.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-pci@atrey.karlin.mff.cuni.cz
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:46371 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933332AbXJTAE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 20:04:28 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9K04MsL028759
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 20:04:22 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9K04MQ2042954
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 18:04:22 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9K04LKc016598
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 18:04:22 -0600
Content-Disposition: inline
In-Reply-To: <1192840577.5369.9.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2007 at 05:36:17PM -0700, Michael Chan wrote:
> On Fri, 2007-10-19 at 18:29 -0500, linas@austin.ibm.com wrote:
> > On Fri, Oct 19, 2007 at 02:36:56PM -0700, Matt Carlson wrote:
> > > This patch exports the pci_restore_msi_state() function.  This function
> > > is needed to restore the MSI state during PCI error recovery.
> > > 
> > > Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> > > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > 
> > Davem,
> > 
> > This patch is generically needed for recovery from PCI errors, 
> > and not just the tg3 that Matt is working on.
> > 
> > Matt, there are also several msi-related bugs in the pseries
> > architecture implementation, those patches will go out to 
> > Paul Mackerras seperately. I was hoping today ... but things 
> > came up. One little iddy-biddy problem is that the pseries
> > is not actually *saving* the msi state, and so, ahem, the 
> > restore isn't quite working out either. I'm still trying
> > to navigate around that.
> > 
> Linas, the MSI state is saved automatically when the driver calls
> pci_enable_msi(), so it doesn't need to be saved by pseries code.

I'm working in linux-2.6.23-rc8-mm1 at the moment, and I don't see
that happening. viz. read_msi_msg() is not called anywhere, and I need
to have valid msg->address_lo and msg->address_hi and msg->data
in order to be able to restore.

In particular, this has to happen after the call to arch_setup_msi_irqs
as otherwise, the arch hasn't yet filled these fields with correct values.

Perhaps this is fixed in the kernel you're working with?

--linas

