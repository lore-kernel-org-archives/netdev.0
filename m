From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-velocity: Give RX descriptors to the NIC later on
 open or MTU change
Date: Fri, 25 Dec 2009 18:21:02 -0800 (PST)
Message-ID: <20091225.182102.112589642.davem@davemloft.net>
References: <1260842710.4532.691.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	508527@bugs.debian.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756451AbZLZCVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2009 21:21:01 -0500
In-Reply-To: <1260842710.4532.691.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 15 Dec 2009 02:05:09 +0000

> velocity_open() calls velocity_give_many_rx_descs(), which gives RX
> descriptors to the NIC, before installing an interrupt handler or
> calling velocity_init_registers().  I think this is very unsafe and it
> appears to explain the bug report <http://bugs.debian.org/508527>.
> 
> On MTU change, velocity_give_many_rx_descs() is again called before
> velocity_init_registers().  I'm not sure whether this is unsafe but
> it does look wrong.
> 
> Therefore, move the calls to velocity_give_many_rx_descs() after
> request_irq() and velocity_init_registers().
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> This is untested; I don't have this hardware.

Although this patch looks fine to me, I don't want to apply
it until someone tests it.
