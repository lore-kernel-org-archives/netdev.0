From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] cxgb4: drop __GFP_NOFAIL allocation
Date: Thu, 16 Apr 2015 12:03:26 -0400 (EDT)
Message-ID: <20150416.120326.749643665082826576.davem@davemloft.net>
References: <552d7781.skJyaStdJ4esZHiL%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org, mhocko@suse.cz,
	david@fromorbit.com, hannes@cmpxchg.org, jack@suse.cz,
	mgorman@suse.de, penguin-kernel@I-love.SAKURA.ne.jp,
	rientjes@google.com, tytso@mit.edu
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbDPQDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:03:30 -0400
In-Reply-To: <552d7781.skJyaStdJ4esZHiL%akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 14 Apr 2015 13:24:33 -0700

> From: Michal Hocko <mhocko@suse.cz>
> Subject: cxgb4: drop __GFP_NOFAIL allocation
> 
> set_filter_wr is requesting __GFP_NOFAIL allocation although it can return
> ENOMEM without any problems obviously (t4_l2t_set_switching does that
> already).  So the non-failing requirement is too strong without any
> obvious reason.  Drop __GFP_NOFAIL and reorganize the code to have the
> failure paths easier.
> 
> The same applies to _c4iw_write_mem_dma_aligned which uses __GFP_NOFAIL
> and then checks the return value and returns -ENOMEM on failure.  This
> doesn't make any sense what so ever.  Either the allocation cannot fail or
> it can.
> 
> del_filter_wr seems to be safe as well because the filter entry is not
> marked as pending and the return value is propagated up the stack up to
> c4iw_destroy_listen.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
 ...
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks.
