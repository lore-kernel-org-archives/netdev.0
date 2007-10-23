From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Mon, 22 Oct 2007 19:13:07 -0500
Message-ID: <20071023001307.GF4280@austin.ibm.com>
References: <1192829817.22064.559.camel@teletran1> <20071021.162131.43417026.davem@davemloft.net> <1193017764.10318.17.camel@concordia> <20071022181336.GC4280@austin.ibm.com> <1193088267.6745.108.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	mcarlson@broadcom.com, linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	mchan@broadcom.com, linux-pci@atrey.karlin.mff.cuni.cz,
	David Miller <davem@davemloft.net>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:59913 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349AbXJWANK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 20:13:10 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9N0D9FH006599
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 20:13:09 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9N0D9e9069958
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 18:13:09 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9N0D8m7028405
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 18:13:09 -0600
Content-Disposition: inline
In-Reply-To: <1193088267.6745.108.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 23, 2007 at 07:24:27AM +1000, Benjamin Herrenschmidt wrote:
> 
> On Mon, 2007-10-22 at 13:13 -0500, Linas Vepstas wrote:
> > On Mon, Oct 22, 2007 at 11:49:24AM +1000, Michael Ellerman wrote:
> > > 
> > > On pseries there's a chance it will work for PCI error recovery, but if
> > > so it's just lucky that firmware has left everything configured the same
> > > way. 
> > 
> > ? The papr is quite clear that i is up to the OS to restore the msi
> > state after an eeh error.
> 
> Via direct config space access or via firmware change-msi calls ?

Direct config space access. It says that the OS is supposed to read the
MSI config (after its been set up), save it, and restore it, (via direct
config space writes) if the device is ever reset.

> I don't know why you keep talking about powerpc laptops here ... 

Well, there are Apple laptops, right?  Aren't those the "powermac" 
platform?  Now, I don't know if they support MSI, but if they do,
I get the impression that they might not restore msi state correctly,
after being put into hardware suspend.  But perhaps I'm mistaken;
I was simply grepping for various msi-related functions in various
arch subdirectories, comparing x86 to other arches, and noticed 
that code that would restore msi state seems to be missing for
most arches and most powerpc platforms.

--linas

