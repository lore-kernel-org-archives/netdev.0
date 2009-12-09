From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/REPOST] net/mpc5200: Fix locking on fec_mpc52xx driver
Date: Tue, 08 Dec 2009 20:28:38 -0800 (PST)
Message-ID: <20091208.202838.78052287.davem@davemloft.net>
References: <20091205043015.28041.19288.stgit@angua>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, a.llano@ziv.es
To: grant.likely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44838
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755736AbZLIE2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:28:31 -0500
In-Reply-To: <20091205043015.28041.19288.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>
Date: Fri, 04 Dec 2009 21:33:13 -0700

> Fix the locking scheme on the fec_mpc52xx driver.  This device can
> receive IRQs from three sources; the FEC itself, the tx DMA, and the
> rx DMA.  Mutual exclusion was handled by taking a spin_lock() in the
> critical regions, but because the handlers are run with IRQs enabled,
> spin_lock() is insufficient and the driver can end up interrupting
> a critical region anyway from another IRQ.
> 
> Asier Llano discovered that this occurs when an error IRQ is raised
> in the middle of handling rx irqs which resulted in an sk_buff memory
> leak.

I'll apply this fix.

But, longer term, it's a thousand times easier and more efficient to
move the processing of these interrupts into softirq context.
