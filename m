From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] tcp: use kmalloc() than kmalloc_array().
Date: Sun, 8 Nov 2015 13:43:04 +0900
Message-ID: <201511081343.FBH04171.OHVLSOtFOMQFFJ@I-love.SAKURA.ne.jp>
References: <1446911439-9235-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<1446922207.17135.9.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151107.142135.2089779750111099230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edumazet@google.com, netdev@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:29246 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbbKHEnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 23:43:19 -0500
In-Reply-To: <20151107.142135.2089779750111099230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 07 Nov 2015 10:50:07 -0800
> 
> > I do not feel we should go back to kmalloc() just because
> > vmalloc_array() does not exist yet.
> 
> Agreed.
> 

Please change as you like.

I was thinking to introduce a helper that does vmalloc() when
kmalloc() failed because locations that do

  ptr = kmalloc(size, GFP_NOFS);
  if (!ptr)
      ptr = vmalloc(size); /* Wrong because GFP_KERNEL is used implicitly */

are found. I just noticed that inet_ehash_locks_alloc() is doing

  ptr = kmalloc_array(count, size, GFP_KERNEL);
  if (!ptr)
      ptr = vmalloc(count * size); /* Wrong because overflow is not checked */

and wanted to know your intent.
