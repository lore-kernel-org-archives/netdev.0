From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Replace 2 jiffies with sysctl
 netdev_budget_usecs to enable softirq tuning
Date: Fri, 21 Apr 2017 16:00:52 -0400 (EDT)
Message-ID: <20170421.160052.848351578908155648.davem@davemloft.net>
References: <1492619830-7561-1-git-send-email-tedheadster@gmail.com>
        <20170421.132245.1207278487695293623.davem@davemloft.net>
        <1492804622.6453.32.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tedheadster@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425803AbdDUUAy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 16:00:54 -0400
In-Reply-To: <1492804622.6453.32.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Apr 2017 12:57:02 -0700

> On Fri, 2017-04-21 at 13:22 -0400, David Miller wrote:
>> From: Matthew Whitehead <tedheadster@gmail.com>
>> Date: Wed, 19 Apr 2017 12:37:10 -0400
>> 
>> > Constants used for tuning are generally a bad idea, especially as hardware
>> > changes over time. Replace the constant 2 jiffies with sysctl variable
>> > netdev_budget_usecs to enable sysadmins to tune the softirq processing.
>> > Also document the variable.
>> > 
>> > For example, a very fast machine might tune this to 1000 microseconds,
>> > while my regression testing 486DX-25 needs it to be 4000 microseconds on
>> > a nearly idle network to prevent time_squeeze from being incremented.
>> > 
>> > Version 2: changed jiffies to microseconds for predictable units.
>> > 
>> > Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>
>> 
>> Applied, thanks.
> 
> Can we revert the changes in kernel/sysctl_binary.c &
> include/uapi/linux/sysctl.h ?
> 
> { CTL_INT,      NET_CORE_BUDGET_USECS,  "netdev_budget_usecs" },
> 
> NET_CORE_BUDGET_USECS=23,
> 
> Unless I am missing something, we should not add new binary sysctls.

That's true, I'll kill this.

====================
[PATCH] net: Remove NET_CORE_BUDGET_USECS from sysctl binary interface.

We are not supposed to add new entries to this thing
any more.

Thanks to Eric Dumazet for noticing this.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/uapi/linux/sysctl.h | 1 -
 kernel/sysctl_binary.c      | 1 -
 2 files changed, 2 deletions(-)

diff --git a/include/uapi/linux/sysctl.h b/include/uapi/linux/sysctl.h
index 177f5f1..e13d480 100644
--- a/include/uapi/linux/sysctl.h
+++ b/include/uapi/linux/sysctl.h
@@ -274,7 +274,6 @@ enum
 	NET_CORE_AEVENT_ETIME=20,
 	NET_CORE_AEVENT_RSEQTH=21,
 	NET_CORE_WARNINGS=22,
-	NET_CORE_BUDGET_USECS=23,
 };
 
 /* /proc/sys/net/ethernet */
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index 4ee3e49..ece4b17 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -197,7 +197,6 @@ static const struct bin_table bin_net_core_table[] = {
 	{ CTL_INT,	NET_CORE_AEVENT_ETIME,	"xfrm_aevent_etime" },
 	{ CTL_INT,	NET_CORE_AEVENT_RSEQTH,	"xfrm_aevent_rseqth" },
 	{ CTL_INT,	NET_CORE_WARNINGS,	"warnings" },
-	{ CTL_INT,	NET_CORE_BUDGET_USECS,	"netdev_budget_usecs" },
 	{},
 };
 
-- 
2.4.11
