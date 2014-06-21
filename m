From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 8/8] enic: do tx cleanup in napi poll
Date: Sat, 21 Jun 2014 15:24:40 -0700 (PDT)
Message-ID: <20140621.152440.2152576710542860161.davem@davemloft.net>
References: <1403077088-4818-1-git-send-email-_govind@gmx.com>
	<1403077088-4818-9-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405AbaFUWYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2014 18:24:42 -0400
In-Reply-To: <1403077088-4818-9-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed, 18 Jun 2014 13:08:08 +0530

> Till now enic had been doing tx clean in isr.
> 
> Using napi infrastructure to move the tx clean up out of isr to softirq.
> Now, wq isr schedules napi poll. In enic_poll_msix_wq we clean up the tx queus.
> 
> This is applicable only on MSIX. In INTx and MSI we use single napi to clean
> both rx & tx queues.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

It is recommended that TX work not count against the quota.

The cost of TX packet liberation is a minute percentage of what it
costs to process an RX frame.  Furthermore, that SKB freeing makes
memory available for other paths in the stack.

So please, just unconditionally purge the entire set of pending TX
queue completion entries without regards to the passed in NAPI quota
value at all.

Thanks.
