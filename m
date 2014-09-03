From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 1/2] net: ethernet: cpsw: don't claim IRQs with devm_request_irq()
Date: Wed, 3 Sep 2014 12:57:37 +0530
Message-ID: <5406C2E9.9010903@ti.com>
References: <1409676245-13897-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <julia.lawall@lip6.fr>, <netdev@vger.kernel.org>,
	<george.cherian@ti.com>
To: Daniel Mack <zonque@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:37771 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750833AbaICH1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 03:27:46 -0400
In-Reply-To: <1409676245-13897-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 02 September 2014 10:14 PM, Daniel Mack wrote:
> Julia Lawall spotted a problem with aa1a15e ("net: ethernet: cpsw:
> switch to devres allocations") which introduced a race condition in
> cpsw_probe() by removing explicit interrupt disable calls before
> calling free_netdev(). Hence, an interrupt can fire after free_netdev()
> was called. The same problem exists in cpsw_remove().
> 
> Fix this by reverting the IRQ part of the aforementioned patch and
> handle those resources explicitly.
> 
> Reported-by: Julia Lawall <julia.lawall@lip6.fr>
> Signed-off-by: Daniel Mack <zonque@gmail.com>

CPSW interrupts cannot be triggered as the interrupts are disabled in
priv->wr_regs->tx_en and priv->wr_regs->rx_en inside CPSW module and
these interrupts are enabled only when the device is opened.

In cpsw_remove, CPDMA controller is stopped and interrupts are disabled
in cpsw_ndo_stop(), so there is no chance that an interrupt can occur
during cpsw_remove().

Regards
Mugunthan V N
