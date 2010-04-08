From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c503: Fix IRQ probing
Date: Wed, 07 Apr 2010 20:56:18 -0700 (PDT)
Message-ID: <20100407.205618.201234628.davem@davemloft.net>
References: <1270398809.8341.47.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	566522@bugs.debian.org, sql7@wp.pl
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53554
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751134Ab0DHD4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 23:56:15 -0400
In-Reply-To: <1270398809.8341.47.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 04 Apr 2010 17:33:29 +0100

> The driver attempts to select an IRQ for the NIC automatically by
> testing which of the supported IRQs are available and then probing
> each available IRQ with probe_irq_{on,off}().  There are obvious race
> conditions here, besides which:
> 1. The test for availability is done by passing a NULL handler, which
>    now always returns -EINVAL, thus the device cannot be opened:
>    <http://bugs.debian.org/566522>
> 2. probe_irq_off() will report only the first ISA IRQ handled,
>    potentially leading to a false negative.
> 
> There was another bug that meant it ignored all error codes from
> request_irq() except -EBUSY, so it would 'succeed' despite this
> (possibly causing conflicts with other ISA devices).  This was fixed
> by ab08999d6029bb2c79c16be5405d63d2bedbdfea 'WARNING: some
> request_irq() failures ignored in el2_open()', which exposed bug 1.
> 
> This patch:
> 1. Replaces the use of probe_irq_{on,off}() with a real interrupt handler
> 2. Adds a delay before checking the interrupt-seen flag
> 3. Disables interrupts on all failure paths
> 4. Distinguishes error codes from the second request_irq() call,
>    consistently with the first
> 
> Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

This looks logically fine, but I'm tossing this into net-next-2.6
because of the limited tester space for this driver.

Thanks Ben.
