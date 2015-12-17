From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/4] Few l2 table related enhancements for
 cxgb4
Date: Thu, 17 Dec 2015 15:52:04 -0500 (EST)
Message-ID: <20151217.155204.320117650010273666.davem@davemloft.net>
References: <1450340110-30031-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754936AbbLQUwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 15:52:06 -0500
In-Reply-To: <1450340110-30031-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu, 17 Dec 2015 13:45:06 +0530

> This series adds a new API to allocate and update l2t entry, replaces
> arpq_head/arpq_tail with double skb double linked list. Use t4_mgmt_tx()
> to send control packets of l2t write request. Use symbolic constants
> while calculating vlan priority.
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.
> 
> Thanks
> 
> V2: Remove unnecessary MAS operation while calculating vlan prio in
>     PATCH 1/4 ("cxgb4: Use symbolic constant for VLAN priority calculation")
>     based on review comment by David Miller

Series applied.

However, while reading over this, it seems to me that e->refcnt doesn't
need to be an atomic_t.  It's always changed under the rwlock, therefore
you can just use non-atomic refcounting.
