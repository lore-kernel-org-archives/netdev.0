From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/9] bnx2x: handle spurious interrupts
Date: Mon, 18 Feb 2013 12:39:02 -0500 (EST)
Message-ID: <20130218.123902.1134119063861292597.davem@davemloft.net>
References: <1361175398-12888-1-git-send-email-yuvalmin@broadcom.com>
	<1361175398-12888-4-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756575Ab3BRRjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 12:39:04 -0500
In-Reply-To: <1361175398-12888-4-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Mon, 18 Feb 2013 10:16:32 +0200

> In scenarios in which a previous driver was removed without proper cleanup
> (e.g., kdump), it is possible for the chip to generate an interrupt without
> any apparent reason.
> This would cause improper behaviour at best, possibly resulting in NULL
> pointer dereferences as interrupts might be sent to an ISR accessing
> uninitialized structures and memories.
> 
> This causes the driver to ignore any interrupt which arrives in an
> inappropriate time, i.e., when the driver has not yet properly configured
> its interrupt routines.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

I cannot accept this patch.

You must not request_irq() until your software state is completely
setup, there are no exceptions to this rule.
