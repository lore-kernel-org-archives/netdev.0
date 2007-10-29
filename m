From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH] Fix ethernet multicast for ucc_geth.
Date: Mon, 29 Oct 2007 18:07:10 +0800
Message-ID: <989B956029373F45A0B8AF0297081890019B6215@zch01exm26.fsl.freescale.net>
References: <1192611942.7848.19.camel@gentoo-jocke.transmode.se> <4725B06F.7070304@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Netdev" <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>, <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:43602 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717AbXJ2KHV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 06:07:21 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id l9TA7DcI003661
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 03:07:13 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l9TA7Bpq024815
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 05:07:12 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <4725B06F.7070304@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > @@ -2255,19 +2253,10 @@ static void 
> ucc_geth_set_multi(struct net_device *dev)
> >  				if (!(dmi->dmi_addr[0] & 1))
> >  					continue;
> >  
> > -				/* The address in dmi_addr is LSB first,
> > -				 * and taddr is MSB first.  We have to
> > -				 * copy bytes MSB first from dmi_addr.
> > -				 */
> > -				mcptr = (u8 *) dmi->dmi_addr + 5;
> > -				tdptr = (u8 *) tempaddr;
> > -				for (j = 0; j < 6; j++)
> > -					*tdptr++ = *mcptr--;
> > -
> >  				/* Ask CPM to run CRC and set bit in
> >  				 * filter mask.
> >  				 */
> > -				hw_add_addr_in_hash(ugeth, tempaddr);
> > +				hw_add_addr_in_hash(ugeth, 
> dmi->dmi_addr);
> 
> did the maintainer ever ACK this?

Yes, I did.  :)

- Leo
