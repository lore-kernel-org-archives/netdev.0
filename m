From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Tue, 23 Oct 2007 07:24:27 +1000
Message-ID: <1193088267.6745.108.camel@pasglop>
References: <1192829817.22064.559.camel@teletran1>
	 <20071021.162131.43417026.davem@davemloft.net>
	 <1193017764.10318.17.camel@concordia>
	 <20071022181336.GC4280@austin.ibm.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	mcarlson@broadcom.com, linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	mchan@broadcom.com, linux-pci@atrey.karlin.mff.cuni.cz,
	David Miller <davem@davemloft.net>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:45847 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750947AbXJVV0w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 17:26:52 -0400
In-Reply-To: <20071022181336.GC4280@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 2007-10-22 at 13:13 -0500, Linas Vepstas wrote:
> On Mon, Oct 22, 2007 at 11:49:24AM +1000, Michael Ellerman wrote:
> > 
> > On pseries there's a chance it will work for PCI error recovery, but if
> > so it's just lucky that firmware has left everything configured the same
> > way. 
> 
> ? The papr is quite clear that i is up to the OS to restore the msi
> state after an eeh error.

Via direct config space access or via firmware change-msi calls ?

> > Yes I think so. That way we can properly reconfigure via the firmware
> > interface. The other option would be to design some new arch hook to do
> > resume, but just doing a disable/enable seems simpler to me.
> 
> Err, If you read the code for suspend/resume, it never actually calls
> disable/enable (and thus doesn't go to the firmware); it calls 
> restore_msi_state() function!
> 
> If suspend/resume needs to call firmware to restore the state, then,
> at the moment, suspend/resume is broken.  As I mentioned earlier,
> I presumed that no powerpc laptops currently use msi-enabled devices,
> as otherwise, this would have been flushed out.

I don't know why you keep talking about powerpc laptops here ... 

Ben.


