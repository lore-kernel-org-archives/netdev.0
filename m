From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Fri, 19 Oct 2007 19:25:27 -0500
Message-ID: <20071020002527.GQ29903@austin.ibm.com>
References: <1192829817.22064.559.camel@teletran1> <20071019232926.GL29903@austin.ibm.com> <1192840577.5369.9.camel@dell> <20071020000421.GO29903@austin.ibm.com> <1192842723.5369.23.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-pci@atrey.karlin.mff.cuni.cz
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:51325 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757091AbXJTAZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 20:25:49 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9K0PdLv017971
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 20:25:39 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9K0PXHx054754
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 18:25:38 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9K0PW8J007557
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 18:25:33 -0600
Content-Disposition: inline
In-Reply-To: <1192842723.5369.23.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2007 at 06:12:03PM -0700, Michael Chan wrote:
> On Fri, 2007-10-19 at 19:04 -0500, linas@austin.ibm.com wrote:
> > I'm working in linux-2.6.23-rc8-mm1 at the moment, and I don't see
> > that happening. viz. read_msi_msg() is not called anywhere, and I need
> > to have valid msg->address_lo and msg->address_hi and msg->data
> > in order to be able to restore.
> > 
> > In particular, this has to happen after the call to
> > arch_setup_msi_irqs
> > as otherwise, the arch hasn't yet filled these fields with correct
> > values.
> > 
> > Perhaps this is fixed in the kernel you're working with?
> 
> It's possible that this doesn't work on pseries.  I've only tested
> pci_restore_msi_state() on x86 in the context of suspend and resume.
> During resume, the MSI state gets restored correctly on x86.

:-) Yes, I think that is being done in arch/i386/kernel/io_apic.c
and arch/ia64/kernel/msi_ia64.c and etc. but its not being done
on most of the powerpc's.  Its possible that none of the
old macintosh laptops use msi, and so no one noticed before; 
I know that no one ever suspends/resumes the big servers I work 
on, sooo :-)

Actually, looking at arch/i386/kernel/io_apic.c, it looks like
the msi state is being saved only when CONFIG_SMP is set, so 
it seems to me that the restore will fail on uni systems ... 
are there any of those left? 

--linas

