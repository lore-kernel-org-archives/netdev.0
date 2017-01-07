From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: inuse checks can quit early for reuseport
Date: Fri, 06 Jan 2017 20:57:07 -0500 (EST)
Message-ID: <20170106.205707.49254629072159860.davem@davemloft.net>
References: <20170106012236.20078-1-e@erig.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: e@erig.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49700 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932326AbdAGB5J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 20:57:09 -0500
In-Reply-To: <20170106012236.20078-1-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Garver <e@erig.me>
Date: Thu,  5 Jan 2017 20:22:36 -0500

> UDP lib inuse checks will walk the entire hash bucket to check if the
> portaddr is in use. In the case of reuseport we can stop searching when
> we find a matching reuseport.
> 
> On a 16-core VM a test program that spawns 16 threads that each bind to
> 1024 sockets (one per 10ms) takes 1m45s. With this change it takes 11s.
> 
> Also add a cond_resched() when the port is not specified.
> 
> Signed-off-by: Eric Garver <e@erig.me>

Applied to net-next.
