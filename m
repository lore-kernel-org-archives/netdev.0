From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH 1/4] ucc_geth: Change private immrbar_virt_to_phys to generic iopa
Date: Thu, 8 Feb 2007 15:06:25 +0800
Message-ID: <989B956029373F45A0B8AF02970818900D440B@zch01exm26.fsl.freescale.net>
References: <17A046C6-5FD3-46D5-AB96-EAEDF22FA829@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Tabi Timur-B04825" <timur@freescale.com>,
	<netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: "Kumar Gala" <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:43639 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422914AbXBHHFN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 02:05:13 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id l1875CFf010266
	for <netdev@vger.kernel.org>; Thu, 8 Feb 2007 00:05:12 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id l18757g4014834
	for <netdev@vger.kernel.org>; Thu, 8 Feb 2007 01:05:09 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <17A046C6-5FD3-46D5-AB96-EAEDF22FA829@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >>>>> If its been mapped with ioremap() you know the physical address
> >>> already
> >>>>> so why do you need iopa().
> >>>>
> >>>> That's what the original function immrbar_virt_to_phys() does.
> > We're
> >>> trying to
> >>>> get rid of it, because we thought is redundant with iopa().
> >>>>
> >>>> static inline unsigned long immrbar_virt_to_phys(volatile void *
> >>> address)
> >>>> {
> >>>> 	if ( ((u32)address >= (u32)qe_immr) &&
> >>>> 			((u32)address < ((u32)qe_immr + QE_IMMAP_SIZE))
> >>> )
> >>>> 		return (unsigned long)(address - (u32)qe_immr +
> >>>> 				(u32)get_qe_base());
> >>>> 	return (unsigned long)virt_to_phys(address);
> >>>> }
> >>>>
> >>>> get_qe_base() does a search of the OF tree the first time it's
> >>>> called.
> >>>>
> >>>> Here's the code that calls immrbar_virt_to_phys():
> >>>>
> >>>> 	out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
> >>>> 		 (u32) immrbar_virt_to_phys(ugeth->
> >>>> 					    p_tx_bd_ring[i]));
> >>>>
> >>>>
> >>>> Would it be better to replace this code with something like this:
> >>>>
> >>>> out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
> >>>> 	get_qe_base() + ((void *) ugeth->p_tx_bd_ring[i] - (void *)
> >>> qe_immr));
> >>>
> >>> No, we don't know if the BD ring is in MURAM or main memory as it
is
> >>> configurable.  iopa() is best choice to handle both case, IMHO.
> >>
> >> Does MURAM behave differently than normal memory?
> >
> > MURAM is a mmio region so it don't share the characteristic of main
> > memory that phy_addr = virt_addr - PAGE_OFFSET.  While they can
> > both be
> > mapped through page table using iopa().
> 
> Right, so when do you know if you'll be using MURAM or normal
> memory?  Why not just keep around a token that is the physical
> address at the point you make the decision of MURAM vs normal memory.

Yes, that can be a way.  But as the virt to phy mapping is only used
once, it's nothing bad to do it this way.

- Leo
