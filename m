From: David Miller <davem@davemloft.net>
Subject: Re: [patch 12/19] fix irq problem with NAPI + NETPOLL
Date: Wed, 07 Mar 2007 15:18:44 -0800 (PST)
Message-ID: <20070307.151844.102573883.davem@davemloft.net>
References: <200703061041.l26AfusT019768@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, anemo@mba.ocn.ne.jp,
	romieu@fr.zoreil.com, shemminger@linux-foundation.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43114
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965725AbXCGXSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 18:18:46 -0500
In-Reply-To: <200703061041.l26AfusT019768@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Tue, 06 Mar 2007 02:41:56 -0800

> From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> 
> It seems netif_receive_skb() was designed not to call from irq context, but
> NAPI + NETPOLL break this rule.  If netif_receive_skb() was called from irq
> context, redirect to netif_rx() instead of processing the skb in that
> context.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

This patch can't be applied, sorry.

netpoll_rx() should be invokable from hardware interrupt context.
What is the crash you are seeing?

It looks like perhaps the kfree_skb() calls need to be modified
in __netpoll_rx().

Stephen?  Maybe this is a result of that set of cleanups you did
to the netpoll code?  It wouldn't surprise me :)
