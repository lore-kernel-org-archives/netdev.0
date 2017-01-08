From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Fix inconsistent rtnl_lock usage on
 dev_get_stats().
Date: Sat, 07 Jan 2017 21:03:24 -0500 (EST)
Message-ID: <20170107.210324.2205499330408276919.davem@davemloft.net>
References: <1483723976.9712.19.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170106.130134.50153126758574257.davem@davemloft.net>
        <1483733603.9712.38.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael.chan@broadcom.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50684 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933164AbdAHCD0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 21:03:26 -0500
In-Reply-To: <1483733603.9712.38.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Jan 2017 12:13:23 -0800

> Well, there are cases where RTNL is quite contended, but supervisions
> like to get /proc/net/devices or various sysfs attributes
> (netstat_show() can be called very very often
> for /sys/class/net/*/statistics/*) in a reasonable amount of time.
> 
> I fear that such a change will add drifts, when devices are constantly
> added/removed.

It stands to reason that RTNETLINK could use pure RCU locking for
device and stat dumps, and frankly that would make their usage and
overhead superior to poking files over and over.
