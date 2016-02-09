From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] tg3: Fix for tg3 transmit queue 0 timed out
 when too many gso_segs
Date: Tue, 09 Feb 2016 04:40:09 -0500 (EST)
Message-ID: <20160209.044009.923938560357961756.davem@davemloft.net>
References: <1454488778-19925-1-git-send-email-siva.kallam@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, prashant@broadcom.com
To: siva.kallam@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756147AbcBIJkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 04:40:14 -0500
In-Reply-To: <1454488778-19925-1-git-send-email-siva.kallam@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: skallam <siva.kallam@broadcom.com>
Date: Wed,  3 Feb 2016 14:09:38 +0530

> From: Siva Reddy Kallam <siva.kallam@broadcom.com>
> 
> tg3_tso_bug() can hit a condition where the entire tx ring is not big
> enough to segment the GSO packet. For example, if MSS is very small,
> gso_segs can exceed the tx ring size. When we hit the condition, it
> will cause tx timeout.
> 
> tg3_tso_bug() is called to handle TSO and DMA hardware bugs.
> For TSO bugs, if tg3_tso_bug() cannot succeed, we have to drop the packet.
> For DMA bugs, we can still fall back to linearize the SKB and let the
> hardware transmit the TSO packet.
> 
> This patch adds a function tg3_tso_bug_gso_check() to check if there
> are enough tx descriptors for GSO before calling tg3_tso_bug().
> The caller will then handle the error appropriately - drop or
> lineraize the SKB.
> 
> v2: Corrected patch description to avoid confusion.
> 
> Signed-off-by: Siva Reddy Kallam <siva.kallam@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Acked-by: Prashant Sreedharan <prashant@broadcom.com>

Applied and queued up for -stable.

Thanks.
