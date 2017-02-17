From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][CFT] Saner error handling in skb_copy_datagram_iter()
 et.al.
Date: Fri, 17 Feb 2017 10:54:20 -0500 (EST)
Message-ID: <20170217.105420.2167024053308682803.davem@davemloft.net>
References: <20170212054209.GQ13195@ZenIV.linux.org.uk>
        <2337836.67BmyCWMtR@debian64>
        <20170214013306.GS13195@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, rlwinm@sdf.org,
        alexmcwhirter@triadic.us, chunkeey@googlemail.com
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44412 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934065AbdBQPyY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 10:54:24 -0500
In-Reply-To: <20170214013306.GS13195@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Tue, 14 Feb 2017 01:33:06 +0000

> OK...  Remaining interesting question is whether it adds a noticable
> overhead.  Could somebody try it on assorted benchmarks and see if
> it slows the things down?  The patch in question follows:

That's about a 40 byte copy onto the stack for each invocation of this
thing.  You can benchmark all you want, but it's clear that this is
non-trivial amount of work and will take some operations from fitting
in the cache to not doing so for sure.
