From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2] rhashtable: unnecessary to use delayed work
Date: Wed, 14 Jan 2015 09:24:03 +0000
Message-ID: <20150114092403.GS20387@casper.infradead.org>
References: <1421206370-27977-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57734 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbbANJYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 04:24:05 -0500
Content-Disposition: inline
In-Reply-To: <1421206370-27977-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/15 at 11:32am, Ying Xue wrote:
> When we put our declared work task in the global workqueue with
> schedule_delayed_work(), its delay parameter is always zero.
> Therefore, we should define a normal work in rhashtable structure
> instead of a delayed work.
> 
> By the way, we add a condition to check whether resizing functions
> are NULL before cancel the work, avoiding to cancel an uninitialized
> work.
> 
> Lastly, while we wait for all work items we submitted before to run
> to completion with cancel_delayed_work(), ht->mutex has been taken in
> rhashtable_destroy(). Moreover, cancel_delayed_work() doesn't return
> until all work items are accomplished, and when work items are
> scheduled, the work's function - rht_deferred_worker() will be called.
> However, as rht_deferred_worker() also needs to acquire the lock,
> deadlock might happen at the moment as the lock is already held before.
> So if the cancel work function is moved out of the lock covered scope,
> this can help to avoid the deadlock.
  ^^^^^^^^^^^^^^^
  will avoid :-)

> 
> Fixes: 97defe1 ("rhashtable: Per bucket locks & deferred expansion/shrinking")
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Cc: Thomas Graf <tgraf@suug.ch>

I don't want to be too picky about the commit title but since this is
fixing a previously reported race condition I would like for that to
be reflected in the title. Something like:

rhashtable: Fix race in rhashtable_destroy() and use regular work_struct

With that fixed:
Acked-by: Thomas Graf <tgraf@suug.ch>
