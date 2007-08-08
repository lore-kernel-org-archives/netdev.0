From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 08 Aug 2007 12:25:14 -0400
Message-ID: <46B9EE6A.1080805@garzik.org>
References: <200708080045.l780jE9E004667@neteffect.com>	<20070808133850.GE14419@one.firstfloor.org>	<200708081548.25399.mb@bu3sch.de> <200708081555.03588.mb@bu3sch.de> <aday7gmov8o.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, Andi Kleen <andi@firstfloor.org>,
	ggrundstrom@neteffect.com, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47758 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753795AbXHHQZT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 12:25:19 -0400
In-Reply-To: <aday7gmov8o.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > But there are indeed a few cases that look wrong.
> 
> yes...
> 
>  > arch/x86_64/kernel/pci-calgary.c:       writel(cpu_to_be32(val), target);
> 
> eg this almost certainly wants to be
> 
> 	writel(swab32(val), target);
> 
> or something equivalent like
> 
> 	__raw_writel(cpu_to_be32(val), target);
> 	/* plus some suffficent memory ordering */

Precisely.  Some of those cases are "we know the underlying writel() 
swaps... we want to swap in this case anyway"

	Jeff



