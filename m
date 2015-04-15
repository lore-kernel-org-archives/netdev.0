From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [patch v2] net: hip04: Make tx coalesce timer actually work
Date: Wed, 15 Apr 2015 12:20:01 +0200
Message-ID: <2657074.k4FFdZD9ci@wuerfel>
References: <alpine.DEB.2.11.1504132338080.3845@nanos> <20150414.141529.797692010779414843.davem@davemloft.net> <alpine.DEB.2.11.1504142140290.3845@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	peterz@infradead.org, mingo@kernel.org, dingtianhong@huawei.com,
	zhangfei.gao@linaro.org, dan.carpenter@oracle.com,
	netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:64864 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817AbbDOKUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 06:20:50 -0400
In-Reply-To: <alpine.DEB.2.11.1504142140290.3845@nanos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 14 April 2015 21:42:42 Thomas Gleixner wrote:
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
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: dingtianhong <dingtianhong@huawei.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Zhangfei Gao <zhangfei.gao@linaro.org>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: netdev@vger.kernel.org
> 

Acked-by: Arnd Bergmann <arnd@arndb.de>
