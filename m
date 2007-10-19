From: "Medve Emilian-EMMEDVE1" <Emilian.Medve@freescale.com>
Subject: RE: [PATCH] [POWERPC] ucc_geth: Eliminate compile warnings
Date: Fri, 19 Oct 2007 06:39:12 -0700
Message-ID: <598D5675D34BE349929AF5EDE9B03E270168520B@az33exm24.fsl.freescale.net>
References: <1192745713-20829-1-git-send-email-Emilian.Medve@Freescale.com> <20071018.173032.48505868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jgarzik@pobox.com>, "Li Yang-r58472" <LeoLi@freescale.com>,
	<netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:42517 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756058AbXJSNjS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 09:39:18 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id l9JDdDbt009097
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 06:39:13 -0700 (MST)
Received: from az33exm24.fsl.freescale.net (az33exm24.am.freescale.net [10.64.32.14])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id l9JDdDTS005418
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2007 08:39:13 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20071018.173032.48505868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David


> It only kills the warning on 32-bit systems, the cast is wrong
> either way.

I'm not aware of the QE being present on any 64-bit PowerPC. However,
porting the entire driver to a 64-bit platform is an exercise in itself
as many other things would need tweaking the QE hardware itself. But
that's an orthogonal issue. For now I just want to fix that warning.

> 
> >  			ugeth->tx_bd_ring_offset[j] =
> > -				kmalloc((u32) (length + align), 
> GFP_KERNEL);
> > +				(u32)kmalloc(length + align, 
> GFP_KERNEL);
> >  
> >  			if (ugeth->tx_bd_ring_offset[j] != 0)
> >  				ugeth->p_tx_bd_ring[j] =
> 
> Pointers can be up to "unsigned long" in size, therefore that
> is the minimal amount of storage you need to store them into
> if they are needed in integer form for some reason.
> 
> Any cast from pointer to integer like this is a huge red flag.

Agreed, but again, I'm not trying to fix the entire driver or to port it
to a different architecture.

For the current situation, 32-bit QE, 32-bit PowerPC, do you find the
patch acceptable?


Cheers,
Emil.
