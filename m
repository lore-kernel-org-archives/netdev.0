From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding with 3c59x driver
Date: Mon, 13 Feb 2012 14:13:11 -0800
Message-ID: <22039.1329171191@death.nxdomain>
References: <201202132253.16496.jdelvare@suse.de>
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	netdev@vger.kernel.org
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:55261 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757266Ab2BMWNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 17:13:21 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 13 Feb 2012 15:13:21 -0700
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id C6B94C90056
	for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 17:13:17 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1DMDHha246602
	for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 17:13:17 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1DMDFXS016091
	for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 17:13:17 -0500
In-reply-to: <201202132253.16496.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jean Delvare <jdelvare@suse.de> wrote:
>I am trying to do network bonding on top of 3com 3C905C ethernet 
>adapters. I am facing the problem that network cable removal isn't 
>detected. It is detected when using Realtek hardware with driver 8139too 
>or VIA hardware with driver via-rhine, but no luck with driver 3c59x. 
>I'm using bonding option miimon=100 for link detection.
>
>Does anyone know if this is a hardware limitation, or a missing feature 
>of the 3c59x driver, or a bug in that driver?

	It just so happens that I was looking at 3c59x earlier today for
something else.  It appears to run its internal link state detection on
a 5 second timer, after which (in theory) bonding's miimon would notice
(provided that the driver notices and calls netif_carrier_off).

	If that's not working, did you try use_carrier=0 to probe the
mii register state directly?

	I have used 3c59x with bonding in the distant past, but I don't
recall exactly what tweaks were necessary; it may have required
use_carrier=0 to work at all.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
