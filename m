From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibm emac: Don't call napi_complete if napi_reschedule
 failed
Date: Fri, 25 Oct 2013 19:13:01 -0400 (EDT)
Message-ID: <20131025.191301.1496864269923138314.davem@davemloft.net>
References: <1382585780-13244-1-git-send-email-alistair@popple.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
To: alistair@popple.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36060 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962Ab3JYXND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:13:03 -0400
In-Reply-To: <1382585780-13244-1-git-send-email-alistair@popple.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alistair Popple <alistair@popple.id.au>
Date: Thu, 24 Oct 2013 14:36:20 +1100

> This patch fixes a bug which would trigger the BUG_ON() at
> net/core/dev.c:4156. It was found that this was due to napi_complete
> being called even when the corresponding call to napi_reschedule had
> failed.
> 
> This patch ensures that we only contine processing rotting packets in
> the current mal_poll call if we are not already on the polling list.
> It also adds locking calls to protect the read-write-modify of the
> MAL_CFG DCR.
> 
> Signed-off-by: Alistair Popple <alistair@popple.id.au>

The mistaken napi_complete() call and the locking change are two different
bugs, fix them in two different patches.
