From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] af_unix: split 'u->readlock' into two: 'iolock'
 and 'bindlock'
Date: Fri, 02 Sep 2016 12:15:34 -0700 (PDT)
Message-ID: <20160902.121534.1390430589343316053.davem@davemloft.net>
References: <alpine.LFD.2.20.1609021109340.4072@i7>
        <CA+55aFyFEhaOaDN9kuphgRV8sDKpV_2xB9X-kpWqMLUtX9JBtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, rweikusat@mobileactivedefense.com,
        edumazet@google.com, w@1wt.eu, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55736 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755305AbcIBTPg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 15:15:36 -0400
In-Reply-To: <CA+55aFyFEhaOaDN9kuphgRV8sDKpV_2xB9X-kpWqMLUtX9JBtQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 2 Sep 2016 11:17:18 -0700

> Oh, this was missing a
> 
>   Reported-and-tested-by: CAI Qian <caiqian@redhat.com>
> 
> who found the new deadlock.
> 
> There's now *another* lockdep deadlock report by him, but that one has
> nothing to do with networking.
> 
> (And neither of these deadlocks will actually deadlock the machine in
> practice, but you can trigger the lockdep reports with some odd splice
> patterns and overlayfs use)

I read over this and can't find any problems.

The main thing I was concerned about was an I/O path that really
expects the socket's hash not to change for whatever reason, but even
all of the unix_find_other() calls are done outside of the mutex
already.
