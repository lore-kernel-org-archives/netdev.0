From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] about net: Fix inconsistent teardown and release of
 private netdev state.
Date: Mon, 21 Aug 2017 14:13:15 -0700 (PDT)
Message-ID: <20170821.141315.2143125372476050164.davem@davemloft.net>
References: <1503062029.4936.173.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170818.155835.2053259542629638150.davem@davemloft.net>
        <1503114001.14953.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41696 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751575AbdHUVNQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 17:13:16 -0400
In-Reply-To: <1503114001.14953.8.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Aug 2017 20:40:01 -0700

> Let look at tun->pcpu_stats, for example.
> 
> It is allocated at line 1831, before the register_netdevice()
> 
> drivers/net/tun.c does not provide ndo_init()

I see the problem now.

And it's done this way because several steps need to occur, with
various kinds of dependencies, before the register_netdevice() call is
made.

I'll see if I can untangle this somehow.
