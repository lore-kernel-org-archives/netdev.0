From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v5 0/8] switchdev: change locking
Date: Thu, 15 Oct 2015 06:10:22 -0700 (PDT)
Message-ID: <20151015.061022.1838627180852828238.davem@davemloft.net>
References: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbbJOMyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 08:54:19 -0400
In-Reply-To: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 14 Oct 2015 19:40:47 +0200

> This is something which I'm currently struggling with.
> Callers of attr_set and obj_add/del often hold not only RTNL, but also
> spinlock (bridge). So in that case, the driver implementing the op cannot sleep.
> 
> The way rocker is dealing with this now is just to invoke driver operation
> and go out, without any checking or reporting of the operation status.
> 
> Since it would be nice to at least put a warning in case the operation fails,
> it makes sense to do this in delayed work directly in switchdev core
> instead of implementing this in separate drivers. And that is what this patchset
> is introducing.
> 
> So from now on, the locking of switchdev mod ops is consistent. Caller either
> holds rtnl mutex or in case it does not, caller sets defer flag, telling
> switchdev core to process the op later, in deferred queue.
> 
> Function to force to process switchdev deferred ops can be called by op
> caller in appropriate location, for example after it releases
> spin lock, to force switchdev core to process pending ops.

Series applied, thanks Jiri.
