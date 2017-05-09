From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Mon, 08 May 2017 22:35:04 -0400 (EDT)
Message-ID: <20170508.223504.1210879210480687536.davem@davemloft.net>
References: <1494288080.7796.59.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170508.212211.1291611254198273979.davem@davemloft.net>
        <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        andreyknvl@google.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45816 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752208AbdEICfH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 22:35:07 -0400
In-Reply-To: <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 08 May 2017 19:18:22 -0700

> Keeping fib (and their reference to netdev) is apparently too much,
> we probably need to implement a refcount on the metrics themselves,
> being stand alone objects.

I think I see the problem, when we flush the dst cache on device
unregister, we point the dst at loopback but do not flush metrics.

I'm going to revert.
