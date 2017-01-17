From: David Miller <davem@davemloft.net>
Subject: Re: Kernel 4.6.7-rt14 kernel workqueue lockup - rtnl deadlock plus
 syscall endless loop
Date: Tue, 17 Jan 2017 12:57:48 -0500 (EST)
Message-ID: <20170117.125748.122599514616047216.davem@davemloft.net>
References: <AM5PR0701MB187338B2418A19E1B4B55C98A07C0@AM5PR0701MB1873.eurprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: EladN@gilat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40222 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750965AbdAQR54 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:57:56 -0500
In-Reply-To: <AM5PR0701MB187338B2418A19E1B4B55C98A07C0@AM5PR0701MB1873.eurprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Nachman <EladN@gilat.com>
Date: Tue, 17 Jan 2017 17:39:03 +0000

> What's more odd about this is that it's very unusual and strange for
> a kernel function to invoke the restart mechanism because a lock is
> being held - the point of the restart mechanism is to allow userspace
> signal handlers to run, so it should only be used when there's a
> signal pending. I think this is a hack in the IPv6 code to work
> around some other issue.

It's not unusal at all, if you actually grep for this under net/ you will
see that it is in fact a common code pattern.

It prevents deadlocks because the sysfs and other nodes that we are
operating with can be unregistered by other threads of control holding
the RTNL mutex.  If we don't break out, we won't release our reference
and therefore the RTNL mutex holding entity cannot make forward
progress.

This behavior is therefore very much intentional.
