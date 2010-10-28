From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4vf: fix crash due to manipulating queues before
 registration
Date: Thu, 28 Oct 2010 13:21:22 -0700 (PDT)
Message-ID: <20101028.132122.245402585.davem@davemloft.net>
References: <1288297007-663-1-git-send-email-leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60838
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934532Ab0J1UU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 16:20:59 -0400
In-Reply-To: <1288297007-663-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Thu, 28 Oct 2010 13:16:47 -0700

> Before commit "net: allocate tx queues in register_netdevice"
> netif_tx_stop_all_queues and related functions could be used between
> device allocation and registration but now only after registration.
> cxgb4 has such a call before registration and crashes now.  Move it
> after register_netdev.
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

Why are you manipulating the queue at all here?

The queue state is "don't care" at this point in time,
and has no meaning until ->open() is invoked.
