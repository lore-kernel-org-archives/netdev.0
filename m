From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Revert "af_unix: Fix splice-bind deadlock"
Date: Sun, 04 Sep 2016 13:29:40 -0700 (PDT)
Message-ID: <20160904.132940.872673973522105066.davem@davemloft.net>
References: <alpine.LFD.2.20.1609021106060.4039@i7>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, rweikusat@mobileactivedefense.com,
        edumazet@google.com, w@1wt.eu, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38690 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754067AbcIDUbC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2016 16:31:02 -0400
In-Reply-To: <alpine.LFD.2.20.1609021106060.4039@i7>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 2 Sep 2016 11:09:23 -0700 (PDT)

> 
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Thu, 1 Sep 2016 14:56:49 -0700
> Subject: [PATCH 1/2] Revert "af_unix: Fix splice-bind deadlock"
> 
> This reverts commit c845acb324aa85a39650a14e7696982ceea75dc1.
> 
> It turns out that it just replaces one deadlock with another one: we can
> still get the wrong lock ordering with the readlock due to overlayfs
> calling back into the filesystem layer and still taking the vfs locks
> after the readlock.
> 
> The proper solution ends up being to just split the readlock into two
> pieces: the bind lock (taken *outside* the vfs locks) and the IO lock
> (taken *inside* the filesystem locks).  The two locks are independent
> anyway.
> 
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

Applied.
