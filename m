From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cipso: simplify cipso_v4_translate() when
 !CONFIG_NETLABEL
Date: Wed, 20 Nov 2013 14:55:11 -0500 (EST)
Message-ID: <20131120.145511.1303114952026497883.davem@davemloft.net>
References: <20131120192548.5616.74526.stgit@localhost>
	<20131120.143407.4095832971724166.davem@davemloft.net>
	<4007061.3MtKnenLV1@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36611 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754938Ab3KTTzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 14:55:13 -0500
In-Reply-To: <4007061.3MtKnenLV1@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Wed, 20 Nov 2013 14:45:19 -0500

> Looking at the original conditional:
> 
>  if ((tag_len == 0) || (opt[opt_iter + 1] > (opt_len - opt_iter))
> 
> ... and the replacement:
> 
>  if ((tag_len == 0) || (tag_len > (opt_len - opt_iter)))
> 
> ... we notice that "(opt[opt_iter + 1] > (opt_len - opt_iter))" has been 
> replaced with "(tag_len > (opt_len - opt_iter))", substituting 'tag_len' for 
> 'opt[opt_iter + 1]'.  This is acceptable because the the first statement in 
> the for loop is:
> 
>  tag_len = opt[opt_iter + 1]
> 
> ... which matches the substitution in the conditional.  I'm not sure how much 
> more explicit I can be about this change, it is really pretty minor.

Then, two things:

1) This is a cleanup, and therefore not suitable for submission right now
   because the net-next tree is closed.

2) A more suitable commit log message would have been "Don't needlessly
   recompute 'opt[opt_iter + 1]' as we already have it stored in tag_len".

   Then anyone who reads this commit message can say "yes, obviously this
   is a correct change and matches what the patch is doing"

Thanks.
