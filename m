From: David Miller <davem@davemloft.net>
Subject: Re: new NAPI interface broken
Date: Wed, 12 Sep 2007 05:50:04 -0700 (PDT)
Message-ID: <20070912.055004.88490155.davem@davemloft.net>
References: <200709071137.02801.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	themann@de.ibm.com, raisch@de.ibm.com
To: ossthema@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:40650
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S967251AbXILMul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:50:41 -0400
In-Reply-To: <200709071137.02801.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan-Bernd Themann <ossthema@de.ibm.com>
Date: Fri, 7 Sep 2007 11:37:02 +0200

> 2) On SMP systems: after netif_rx_complete has been called on CPU1
>    (+interruts enabled), netif_rx_schedule could be called on CPU2 
>    (irq handler) before net_rx_action on CPU1 has checked NAPI_STATE_SCHED. 
>    In that case the device would be added to poll lists of CPU1 and CPU2
>    as net_rx_action would see NAPI_STATE_SCHED set.
>    This must not happen. It will be caught when netif_rx_complete is
>    called the second time (BUG() called)
> 
> This would mean we have a problem on all SMP machines right now.

This is not a correct statement.

Only on your platform do network device interrupts get moved
around, no other platform does this.

Sparc64 doesn't, all interrupts stay in one location after
the cpu is initially choosen.

x86 and x86_64 specifically do not move around network
device interrupts, even though other device types do
get dynamic IRQ cpu distribution.

That's why you are the only person seeing this problem.

I agree that it should be fixed, but we should also fix the IRQ
distribution scheme used on powerpc platforms which is totally
broken in these cases.
