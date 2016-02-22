From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] gianfar: Map head TxBD first to skip a
 wmb()
Date: Sun, 21 Feb 2016 21:58:43 -0500 (EST)
Message-ID: <20160221.215843.877041303205905380.davem@davemloft.net>
References: <1455878854-28290-1-git-send-email-claudiu.manoil@freescale.com>
	<1455878854-28290-2-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbcBVC6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 21:58:45 -0500
In-Reply-To: <1455878854-28290-2-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Fri, 19 Feb 2016 12:47:32 +0200

> The main point of this change is to update the buffer pointer of
> the first BD way before the status field is updated, so that a
> wmb() between these two operations is no longer needed.

This is the completely bogus.

The distance between two memory operations has no bearing upon
whether a memory barrier is necessary between them or not.

There could be 1,000 loads and stores between two dependant
operations, you still need the memory barrier for full correctness
if the ordering between them is important.

I am not applying this patch series because it's is doing things
and stating things which are entirely incorrect.

Sorry.
