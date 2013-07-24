From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/1] r8169: fix lockdep warning when removing
 interface
Date: Wed, 24 Jul 2013 15:43:37 -0700 (PDT)
Message-ID: <20130724.154337.318987942705079482.davem@davemloft.net>
References: <3190648.uJuPIZ6zlh@al>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, nic_swsd@realtek.com
To: lekensteyn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805Ab3GXWni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 18:43:38 -0400
In-Reply-To: <3190648.uJuPIZ6zlh@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Wu <lekensteyn@gmail.com>
Date: Mon, 22 Jul 2013 09:53:30 +0200

> The work queue is initialised in rtl_open (when the interface goes up),
> but canceled in rtl_remove_one (when the PCI device gets removed). If
> the network interface is not brought up, then the work queue struct is
> not initialised. When the device is removed, the attempt to cancel the
> uninitialised work queue causes a lockdep warning.
> 
> This patch fixes the issue by moving cancel_work_sync to rtl_close (to
> match rtl_open). (Note that rtl_close is also called via
> unregister_netdev in rtl_remove_one.)
> 
> Signed-off-by: Peter Wu <lekensteyn@gmail.com>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied, thanks.
