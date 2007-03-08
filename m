From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [patch 12/19] fix irq problem with NAPI + NETPOLL
Date: Thu, 08 Mar 2007 10:35:13 +0900 (JST)
Message-ID: <20070308.103513.103776988.nemoto@toshiba-tops.co.jp>
References: <200703061041.l26AfusT019768@shell0.pdx.osdl.net>
	<20070307.151844.102573883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from topsns2.toshiba-tops.co.jp ([202.230.225.126]:7750 "EHLO
	topsns2.toshiba-tops.co.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S2992818AbXCHBfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 20:35:19 -0500
In-Reply-To: <20070307.151844.102573883.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 07 Mar 2007 15:18:44 -0800 (PST), David Miller <davem@davemloft.net> wrote:
> netpoll_rx() should be invokable from hardware interrupt context.
> What is the crash you are seeing?

The problem is not netpoll_rx().  It should be called from irq context.
The problem is, netif_receive_skb() is called from irq context though
it seems not designed to do so.

> It looks like perhaps the kfree_skb() calls need to be modified
> in __netpoll_rx().

Well, it seems an another netpoll bug.
---
Atsushi Nemoto
