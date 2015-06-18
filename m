From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: fix br_stp_set_bridge_priority race
 conditions
Date: Thu, 18 Jun 2015 03:31:01 -0700 (PDT)
Message-ID: <20150618.033101.604712116094406473.davem@davemloft.net>
References: <1434389331-2376-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	joerg@higgsboson.tk
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977AbbFRKTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 06:19:20 -0400
In-Reply-To: <1434389331-2376-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Mon, 15 Jun 2015 20:28:51 +0300

> After the ->set() spinlocks were removed br_stp_set_bridge_priority
> was left running without any protection when used via sysfs. It can
> race with port add/del and could result in use-after-free cases and
> corrupted lists. Tested by running port add/del in a loop with stp
> enabled while setting priority in a loop, crashes are easily
> reproducible.
> The spinlocks around sysfs ->set() were removed in commit:
> 14f98f258f19 ("bridge: range check STP parameters")
> There's also a race condition in the netlink priority support that is
> fixed by this change, but it was introduced recently and the fixes tag
> covers it, just in case it's needed the commit is:
> af615762e972 ("bridge: add ageing_time, stp_state, priority over netlink")
> 
> Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
> Fixes: 14f98f258f19 ("bridge: range check STP parameters")

Applied and queued up for -stable, thanks.
