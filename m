From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: Fix refcnt on host routes
Date: Thu, 03 Mar 2016 17:26:45 -0500 (EST)
Message-ID: <20160303.172645.1966494270005653336.davem@davemloft.net>
References: <1456947007-32444-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avagin@gmail.com,
	ying.huang@linux.intel.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758487AbcCCW0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 17:26:47 -0500
In-Reply-To: <1456947007-32444-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  2 Mar 2016 11:30:07 -0800

> Andrew and Ying Huang's test robot both reported usage count problems that
> trace back to the 'keep address on ifdown' patch.
> 
> From Andrew:
> We execute CRIU test on linux-next. On the current linux-next kernel
> they hangs on creating a network namespace.
> 
> The kernel log contains many massages like this:
> [ 1036.122108] unregister_netdevice: waiting for lo to become free.
> Usage count = 2
> [ 1046.165156] unregister_netdevice: waiting for lo to become free.
> Usage count = 2
> [ 1056.210287] unregister_netdevice: waiting for lo to become free.
> Usage count = 2
> 
> I tried to revert this patch and the bug disappeared.
> 
> Here is a set of commands to reproduce this bug:
> 
> [root@linux-next-test linux-next]# uname -a
> Linux linux-next-test 4.5.0-rc6-next-20160301+ #3 SMP Wed Mar 2
> 17:32:18 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
> 
> [root@linux-next-test ~]# unshare -n
> [root@linux-next-test ~]# ip link set up dev lo
> [root@linux-next-test ~]# ip a
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
> group default qlen 1
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>     inet 127.0.0.1/8 scope host lo
>        valid_lft forever preferred_lft forever
>     inet6 ::1/128 scope host
>        valid_lft forever preferred_lft forever
> [root@linux-next-test ~]# logout
> [root@linux-next-test ~]# unshare -n
> 
>  -----
> 
> The problem is a change made to RTM_DELADDR case in __ipv6_ifa_notify that
> was added in an early version of the offending patch and is no longer
> needed.
> 
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Cc: Andrey Wagin <avagin@gmail.com>
> Cc: Ying Huang <ying.huang@linux.intel.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.
