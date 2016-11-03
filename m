From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dccp: do not release listeners too soon
Date: Thu, 03 Nov 2016 16:19:27 -0400 (EDT)
Message-ID: <20161103.161927.2250111271074026849.davem@davemloft.net>
References: <CAAeHK+yZ4WF2eXATVFQbe_SKM-MFzXypA6VjGxwUxYV3_4xT9g@mail.gmail.com>
        <1478132081.7065.403.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com, gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org,
        netdev@vger.kernel.org, dvyukov@google.com, glider@google.com,
        kcc@google.com, edumazet@google.com, syzkaller@googlegroups.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42506 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752138AbcKCUTa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:19:30 -0400
In-Reply-To: <1478132081.7065.403.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Nov 2016 17:14:41 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Andrey Konovalov reported following error while fuzzing with syzkaller :
 ...
> It turns out DCCP calls __sk_receive_skb(), and this broke when
> lookups no longer took a reference on listeners.
> 
> Fix this issue by adding a @refcounted parameter to __sk_receive_skb(),
> so that sock_put() is used only when needed.
> 
> Fixes: 3b24d854cb35 ("tcp/dccp: do not touch listener sk_refcnt under synflood")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable.
