From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] switchdev: Require RTNL mutex to be held when
 sending FDB notifications
Date: Thu, 28 Jan 2016 16:22:15 -0800 (PST)
Message-ID: <20160128.162215.1495832301297951482.davem@davemloft.net>
References: <1453904203-4908-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org, sfeldma@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60158 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbcA2AWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 19:22:16 -0500
In-Reply-To: <1453904203-4908-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 27 Jan 2016 15:16:43 +0100

> From: Ido Schimmel <idosch@mellanox.com>
> 
> When switchdev drivers process FDB notifications from the underlying
> device they resolve the netdev to which the entry points to and notify
> the bridge using the switchdev notifier.
> 
> However, since the RTNL mutex is not held there is nothing preventing
> the netdev from disappearing in the middle, which will cause
> br_switchdev_event() to dereference a non-existing netdev.
> 
> Make switchdev drivers hold the lock at the beginning of the
> notification processing session and release it once it ends, after
> notifying the bridge.
> 
> Also, remove switchdev_mutex and fdb_lock, as they are no longer needed
> when RTNL mutex is held.
> 
> Fixes: 03bf0c281234 ("switchdev: introduce switchdev notifier")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied and queued up for -stable, thanks Jiri.
