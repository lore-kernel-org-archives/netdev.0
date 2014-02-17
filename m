From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] bonding: Fix RTNL: assertion failed at
 net/core/rtnetlink.c
Date: Mon, 17 Feb 2014 16:36:02 -0500 (EST)
Message-ID: <20140217.163602.224148895821804736.davem@davemloft.net>
References: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	cwang@twopensource.com, jiri@resnulli.us, thomas@glanzmann.de,
	eric.dumazet@gmail.com, sfeldma@cumulusnetworks.com,
	netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbaBQVgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 16:36:05 -0500
In-Reply-To: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Mon, 17 Feb 2014 16:35:48 +0800

> The problem was introduced by the commit 1d3ee88ae0d
> (bonding: add netlink attributes to slave link dev).
> The bond_set_active_slave() and bond_set_backup_slave()
> will use rtmsg_ifinfo to send slave's states, so these
> two functions should be called in RTNL.
> 
> In 802.3ad mode, acquiring RTNL for the __enable_port and
> __disable_port cases is difficult, as those calls generally
> already hold the state machine lock, and cannot unconditionally
> call rtnl_lock because either they already hold RTNL (for calls
> via bond_3ad_unbind_slave) or due to the potential for deadlock
> with bond_3ad_adapter_speed_changed, bond_3ad_adapter_duplex_changed,
> bond_3ad_link_change, or bond_3ad_update_lacp_rate.  All four of
> those are called with RTNL held, and acquire the state machine lock
> second.  The calling contexts for __enable_port and __disable_port
> already hold the state machine lock, and may or may not need RTNL.
> 
> According to the Jay's opinion, I don't think it is a problem that
> the slave don't send notify message synchronously when the status
> changed, normally the state machine is running every 100 ms, send
> the notify message at the end of the state machine if the slave's
> state changed should be better.

I would like to ask you to combine these three changes into one
patch.

Thank you.
