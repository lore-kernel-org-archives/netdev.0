From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH 1/2] Revert "af_unix: Fix splice-bind deadlock"
Date: Sat, 3 Sep 2016 20:00:13 +0300
Message-ID: <20160903200013.14111d91@halley>
References: <alpine.LFD.2.20.1609021106060.4039@i7>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Eric Dumazet <edumazet@google.com>, willy tarreau <w@1wt.eu>,
        netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36420 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753422AbcICRA1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2016 13:00:27 -0400
Received: by mail-wm0-f68.google.com with SMTP id i138so6989723wmf.3
        for <netdev@vger.kernel.org>; Sat, 03 Sep 2016 10:00:26 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.20.1609021106060.4039@i7>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Sep 2016 11:09:23 -0700 (PDT) Linus Torvalds <torvalds@linux-foundation.org> wrote:
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
> ---
> 
> This is not a completely clean revert, because other changes had happened 
> in this area since that commit, but the conflicts were pretty trivial.

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
