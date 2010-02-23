From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tc35815: Remove a wrong netif_wake_queue() call which
 triggers BUG_ON
Date: Tue, 23 Feb 2010 01:25:58 -0800 (PST)
Message-ID: <20100223.012558.174368647.davem@davemloft.net>
References: <1266592438-10772-1-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf.roesch@rw-gmbh.de
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56523
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752102Ab0BWJZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 04:25:40 -0500
In-Reply-To: <1266592438-10772-1-git-send-email-anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Sat, 20 Feb 2010 00:13:58 +0900

> The netif_wake_queue() is called correctly (i.e. only on !txfull
> condition) from txdone routine.  So Unconditional call to the
> netif_wake_queue() here is wrong.  This might cause calling of
> start_xmit routine on txfull state and trigger BUG_ON.
> 
> This bug does not happen when NAPI disabled.  After txdone there
> must be at least one free tx slot.  But with NAPI, this is not
> true anymore and the BUG_ON can hits on heavy load.
> 
> In this driver NAPI was enabled on 2.6.33-rc1 so this is
> regression from 2.6.32 kernel.
> 
> Reported-by: Ralf Roesch <ralf.roesch@rw-gmbh.de>
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Patch applied, thanks.
