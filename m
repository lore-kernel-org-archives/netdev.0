From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] tcp: use kmalloc() than kmalloc_array().
Date: Sun, 8 Nov 2015 00:58:50 +0900
Message-ID: <201511080058.FBI87526.FLOVOtFHJMQSOF@I-love.SAKURA.ne.jp>
References: <1446911439-9235-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:43370 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528AbbKGP66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 10:58:58 -0500
In-Reply-To: <1446911439-9235-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tetsuo Handa wrote:
> Commit 095dc8e0c3686d58 ("tcp: fix/cleanup inet_ehash_locks_alloc()")
> silently changed from kmalloc() to kmalloc_array(). The latter has
> overflow check whereas the former doesn't have.
> 
> If nblocks * locksz might overflow, we need to do like
> 
>   -  if (!hashinfo->ehash_locks && nblocks > SIZE_MAX / locksz)
>   +  if (!hashinfo->ehash_locks && nblocks > SIZE_MAX / locksz)

Oops, I meant

   -  if (!hashinfo->ehash_locks)
   +  if (!hashinfo->ehash_locks && nblocks > SIZE_MAX / locksz)

here.

>        hashinfo->ehash_locks = vmalloc(nblocks * locksz);
> 
> because kmalloc_array() detects overflow and returns NULL.
> But if nblocks * locksz is guaranteed not to overflow, there is
> no need to use kmalloc_array().
> 
> Since I assume it won't overflow, use kmalloc() than kmalloc_array().

I don't know about possible value range.
Please confirm that it can't overflow.
