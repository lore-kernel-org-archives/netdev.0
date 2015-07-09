From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: Fix shared IRQ handling
Date: Wed, 08 Jul 2015 23:37:48 -0700 (PDT)
Message-ID: <20150708.233748.252170826314642014.davem@davemloft.net>
References: <1436294935-21777-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dvlasenk@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbbGIGhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 02:37:48 -0400
In-Reply-To: <1436294935-21777-1-git-send-email-dvlasenk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Tue,  7 Jul 2015 20:48:55 +0200

> As its first order of business, boomerang_interrupt() checks whether
> the device really has any pending interrupts. If it does not,
> it does nothing and returns, but it still returns IRQ_HANDLED.
> 
> This is wrong: interrupt was not handled, IRQ handlers of other
> devices sharing this IRQ line need to be called.
> 
> vortex_interrupt() has it right: it returns IRQ_NONE in this case
> via IRQ_RETVAL(0).
> 
> Do the same in boomerang_interrupt().
> 
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>

Looks good, applied, thanks Denys.
