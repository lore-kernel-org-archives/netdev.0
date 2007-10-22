From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Mon, 22 Oct 2007 13:19:33 -0500
Message-ID: <20071022181933.GD4280@austin.ibm.com>
References: <20071021.162131.43417026.davem@davemloft.net> <1551EAE59135BE47B544934E30FC4FC002AABB04@nt-irva-0751.brcm.ad.broadcom.com> <20071021.214520.66310568.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, mcarlson@broadcom.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:47699 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884AbXJVSTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 14:19:37 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9MIL6MS003470
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 14:21:07 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MIJYGN107874
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 14:19:34 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MIJXvC021023
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 14:19:34 -0400
Content-Disposition: inline
In-Reply-To: <20071021.214520.66310568.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 21, 2007 at 09:45:20PM -0700, David Miller wrote:
> 
> The core issue is that the ARCH level MSI code invokes
> write_msi_msg(), not the generic code, exactly because there
> are platform level issues wherein the firmware is the only
> legal way to write the MSI settings in PCI config space.
> 
> However, the MSI state restore code was not architected similarly.  It
> does the write_msi_msg() directly, instead of letting platform level
> code is in ARCH hooks.

Yes, exactly.

> Therefore I think we need to attack this in two stages:
> 
> 1) First changeset moves the write_msi_msg() call currently in
>    __pci_restore_msi_state() into an ARCH overridable handler.
> 
>    This would allow powerpc to deal with this properly.

Yes!
I'll try to put together a patch later today, if I can get
a fabled "round tuit".

>    pci_restor_msi_state() can get exported to modules in this
>    change

OK.

> 2) The Tigon3 error recovery changes, as they were.
> 
> But I have to ask, can anyone see how e1000 handles MSI properly
> in it's PCI error support?

It doesn't. None of them do. :-(  I didn't get access to msi-capable 
hardware until a few weeks ago; that's why this is coming up just now.

--linas
