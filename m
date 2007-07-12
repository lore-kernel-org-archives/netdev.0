From: David Miller <davem@davemloft.net>
Subject: Re: [1/5][TG3]: Fix irq_sync race condition.
Date: Wed, 11 Jul 2007 19:47:29 -0700 (PDT)
Message-ID: <20070711.194729.51420145.davem@davemloft.net>
References: <1184196705.5211.8.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, gaagaan@gmail.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46236
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764457AbXGLCrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 22:47:06 -0400
In-Reply-To: <1184196705.5211.8.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 11 Jul 2007 16:31:45 -0700

> [TG3]: Fix irq_sync race condition.
> 
> Gagan Arneja <gaagaan@gmail.com> pointed out that tg3_reset_task()
> could potentially race with another thread calling tg3_full_lock()
> such as the ethtool_set_xxx() functions.  This may trigger the
> BUG_ON() in tg3_irq_quiesce() or cause the irq_sync flag to be out-
> of-sync.
> 
> I think the easiest way to fix this is to get the tp->lock first
> before setting the irq_sync flag.  This is safe to do because the
> tp->lock is never grabbed by the irq handler.  This change will
> guarantee that the irq_sync flag updates will be serialized.  We also
> have to change one spot to call tg3_netif_start() (which clears the
> irq_sync flag) before releasing the tp->lock.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
