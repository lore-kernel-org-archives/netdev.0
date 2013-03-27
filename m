From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: handle spurious interrupts
Date: Wed, 27 Mar 2013 15:27:16 -0400 (EDT)
Message-ID: <20130327.152716.1731476572805884795.davem@davemloft.net>
References: <1364408379-4353-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753849Ab3C0T1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 15:27:19 -0400
In-Reply-To: <1364408379-4353-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Wed, 27 Mar 2013 20:19:39 +0200

> Since the driver must request the IRQ prior to enabling HW generation of
> interrupts, it would still need to ignore every interrupt arriving during that
> interval.

This is the real issue.

request_irq() must not be invoked until you are ready to handle
interrupts, and this means initializing any and all software
datastructures that might be accessed in the interrupt handler.

If this requirement is met, seeing NULL pointers is not possible.

I still reject this patch, please fix the fundamental issue instead,
thanks.
