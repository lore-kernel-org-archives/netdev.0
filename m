From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] rhashtable: Fix race in
 rhashtable_destroy() and use regular work_struct
Date: Fri, 16 Jan 2015 01:19:08 -0500 (EST)
Message-ID: <20150116.011908.853329937373201456.davem@davemloft.net>
References: <1421377989-7891-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbbAPGTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 01:19:10 -0500
In-Reply-To: <1421377989-7891-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Fri, 16 Jan 2015 11:13:09 +0800

> When we put our declared work task in the global workqueue with
> schedule_delayed_work(), its delay parameter is always zero.
> Therefore, we should define a regular work in rhashtable structure
> instead of a delayed work.
> 
> By the way, we add a condition to check whether resizing functions
> are NULL before cancelling the work, avoiding to cancel an
> uninitialized work.
> 
> Lastly, while we wait for all work items we submitted before to run
> to completion with cancel_delayed_work(), ht->mutex has been taken in
> rhashtable_destroy(). Moreover, cancel_delayed_work() doesn't return
> until all work items are accomplished, and when work items are
> scheduled, the work's function - rht_deferred_worker() will be called.
> However, as rht_deferred_worker() also needs to acquire the lock,
> deadlock might happen at the moment as the lock is already held before.
> So if the cancel work function is moved out of the lock covered scope,
> this will avoid the deadlock.
> 
> Fixes: 97defe1 ("rhashtable: Per bucket locks & deferred expansion/shrinking")
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Cc: Thomas Graf <tgraf@suug.ch>
> Acked-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
