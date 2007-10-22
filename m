From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [BUG] powerpc does not save msi state [was Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Mon, 22 Oct 2007 14:54:52 -0500
Message-ID: <20071022195451.GE4280@austin.ibm.com>
References: <20071020000421.GO29903@austin.ibm.com> <20071019.172706.57467960.davem@davemloft.net> <20071020004610.GR29903@austin.ibm.com> <20071019.175308.54212640.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, mchan@broadcom.com, mcarlson@broadcom.com,
	netdev@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz,
	michael@ellerman.id.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:49488 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752780AbXJVTyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 15:54:53 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9MJsreH028797
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 15:54:53 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MJsrwY084288
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 13:54:53 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MJsqJU001414
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 13:54:53 -0600
Content-Disposition: inline
In-Reply-To: <20071019.175308.54212640.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2007 at 05:53:08PM -0700, David Miller wrote:
> From: linas@austin.ibm.com (Linas Vepstas)
> Date: Fri, 19 Oct 2007 19:46:10 -0500
> 
> > FWIW, it looks like not all that many arches do this; the output
> > for grep -r address_hi * is pretty thin. Then, looking at
> > i386/kernel/io_apic.c as an example, one can see that the 
> > msi state save happens "by accident" if CONFIG_SMP is enabled;
> > and so its surely broekn on uniprocesor machines.
> 
> I don't see this, in all cases write_msi_msg() will transfer
> the given "*msg" to entry->msg by this assignment in
> drivers/pci/msi.c:
> 
> void write_msi_msg(unsigned int irq, struct msi_msg *msg)
> {
>  ...
> 	entry->msg = *msg;
> }
> 
> So as long as write_msi_msg() is invoked, it will be saved
> properly.

As Michael Ellerman points out, the pseries msi setup is done
by firmware, and so this bit never happens. 

As discussed in the other thread, I'll try to set up a patch
for an arch callback for restoring msi state.

-linas
