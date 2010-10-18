From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ns83820: spin_lock_irq() => spin_lock()
Date: Mon, 18 Oct 2010 01:53:49 -0700 (PDT)
Message-ID: <20101018.015349.226761791.davem@davemloft.net>
References: <20101013191852.GD6060@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	mingo@elte.hu
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42838
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751585Ab0JRIx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 04:53:26 -0400
In-Reply-To: <20101013191852.GD6060@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 13 Oct 2010 21:18:53 +0200

> This is essentially cosmetic.  At this point the IRQs are already
> disabled because we called spin_lock_irq(&dev->rx_info.lock).
> 
> The real bug here was fixed back in 2006 in 3a10ccebe: "[PATCH] lock
> validator: fix ns83820.c irq-flags bug".  Prior to that patch, it was
> a "spin_lock_irq is not nestable" type bug.  The 2006 patch changes the
> unlock to not re-enable IRQs, which eliminates the potential deadlock.
> 
> But this bit was missed.  We should change the lock function as well so
> it balances nicely.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
