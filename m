From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] random32: avoid attempt to late reseed if in
 the middle of seeding
Date: Fri, 28 Mar 2014 16:05:05 -0400 (EDT)
Message-ID: <20140328.160505.484294950792471809.davem@davemloft.net>
References: <1396024722-11632-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	sasha.levin@oracle.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817AbaC1UFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 16:05:07 -0400
In-Reply-To: <1396024722-11632-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 28 Mar 2014 17:38:42 +0100

> From: Sasha Levin <sasha.levin@oracle.com>
> 
> Commit 4af712e8df ("random32: add prandom_reseed_late() and call when
> nonblocking pool becomes initialized") has added a late reseed stage
> that happens as soon as the nonblocking pool is marked as initialized.
> 
> This fails in the case that the nonblocking pool gets initialized
> during __prandom_reseed()'s call to get_random_bytes(). In that case
> we'd double back into __prandom_reseed() in an attempt to do a late
> reseed - deadlocking on 'lock' early on in the boot process.
> 
> Instead, just avoid even waiting to do a reseed if a reseed is already
> occuring.
> 
> Fixes: 4af712e8df99 ("random32: add prandom_reseed_late() and call when nonblocking pool becomes initialized")
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  Recommended for -stable as well. I'm resending the patch as v2
>  from [1] does not apply to the tree, perhaps some mail client
>  issue ...
> 
>  [1] http://patchwork.ozlabs.org/patch/334223/

Applied and queued up for -stable, thanks everyone.
