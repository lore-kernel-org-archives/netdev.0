From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] net: hip04: Make tx coalesce timer actually work
Date: Wed, 15 Apr 2015 17:22:27 -0400 (EDT)
Message-ID: <20150415.172227.1813336970100255734.davem@davemloft.net>
References: <alpine.DEB.2.11.1504140007570.3845@nanos>
	<20150414.141529.797692010779414843.davem@davemloft.net>
	<alpine.DEB.2.11.1504142140290.3845@nanos>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, linux-kernel@vger.kernel.org, peterz@infradead.org,
	mingo@kernel.org, dingtianhong@huawei.com, zhangfei.gao@linaro.org,
	dan.carpenter@oracle.com, netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654AbbDOVW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 17:22:29 -0400
In-Reply-To: <alpine.DEB.2.11.1504142140290.3845@nanos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 14 Apr 2015 21:42:42 +0200 (CEST)

> The code sets the expiry value of the timer to a relative value and
> starts it with hrtimer_start_expires. That's fine, but that only works
> once. The timer is started in relative mode, so the expiry value gets
> overwritten with the absolut expiry time (now + expiry).
> 
> So once the timer expired, a new call to hrtimer_start_expires results
> in an immidiately expired timer, because the expiry value is
> already in the past.
> 
> Use the proper mechanisms to (re)start the timer in the intended way.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Applied, thanks Thomas.
