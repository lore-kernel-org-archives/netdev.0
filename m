From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Mon, 22 Oct 2007 13:13:37 -0500
Message-ID: <20071022181336.GC4280@austin.ibm.com>
References: <1192829817.22064.559.camel@teletran1> <20071021.162131.43417026.davem@davemloft.net> <1193017764.10318.17.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mcarlson@broadcom.com,
	netdev@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz,
	mchan@broadcom.com, linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Michael Ellerman <michael@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:43296 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755283AbXJVSNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 14:13:53 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9MIDqRL013160
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 14:13:52 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MIDckW086316
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 12:13:39 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MIDbkw023073
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 12:13:38 -0600
Content-Disposition: inline
In-Reply-To: <1193017764.10318.17.camel@concordia>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 22, 2007 at 11:49:24AM +1000, Michael Ellerman wrote:
> 
> On pseries there's a chance it will work for PCI error recovery, but if
> so it's just lucky that firmware has left everything configured the same
> way. 

? The papr is quite clear that i is up to the OS to restore the msi
state after an eeh error.

> Yes I think so. That way we can properly reconfigure via the firmware
> interface. The other option would be to design some new arch hook to do
> resume, but just doing a disable/enable seems simpler to me.

Err, If you read the code for suspend/resume, it never actually calls
disable/enable (and thus doesn't go to the firmware); it calls 
restore_msi_state() function!

If suspend/resume needs to call firmware to restore the state, then,
at the moment, suspend/resume is broken.  As I mentioned earlier,
I presumed that no powerpc laptops currently use msi-enabled devices,
as otherwise, this would have been flushed out.

--linas


