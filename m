From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] be2net: fix wrong frag_idx reported by RX CQ
Date: Tue, 18 Dec 2012 16:19:09 -0800 (PST)
Message-ID: <20121218.161909.1898708299603036704.davem@davemloft.net>
References: <1355809131-8924-1-git-send-email-sathya.perla@emulex.com>
	<42b4ddf1-1024-4762-b86c-66c033afc219@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755039Ab2LSATJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 19:19:09 -0500
In-Reply-To: <42b4ddf1-1024-4762-b86c-66c033afc219@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 18 Dec 2012 11:08:51 +0530

> The RX CQ can report completions with invalid frag_idx when the RXQ that
> was *previously* using it, was not cleaned up properly. This hits
> a BUG_ON() in be2net.
> 
> When completion coalescing is enabled on a CQ, an explicit CQ-notify
> (with rearm) is needed for each compl, to flush partially coalesced CQ
> entries that are pending DMA.
> 
> In be_close(), this fix now notifies CQ for each compl, waits explicitly
> for the flush compl to arrive and complains if it doesn't arrive.
> 
> Also renaming be_crit_error() to be_hw_error() as it's the more
> appropriate name and to convey that we don't wait for the flush compl
> only when a HW error has occurred.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
