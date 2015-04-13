From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [patch 4/5] net: hip04: Make tx coalesce timer actually work
Date: Tue, 14 Apr 2015 00:03:12 +0200
Message-ID: <3040901.Bp3bfgc1te@wuerfel>
References: <20150413210009.682000343@linutronix.de> <9614284.QjZ4xls6zV@wuerfel> <alpine.DEB.2.11.1504132338080.3845@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	dingtianhong <dingtianhong@huawei.com>,
	Zhangfei Gao <zhangfei.gao@linaro.org>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:50951 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbbDMWEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 18:04:02 -0400
In-Reply-To: <alpine.DEB.2.11.1504132338080.3845@nanos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 13 April 2015 23:42:03 Thomas Gleixner wrote:
> > 
> > Question: this looks to me like it sets both the minimum and maximum
> > time to priv->tx_coalesce_usecs/2, when the intention was to set
> > the minimum to priv->tx_coalesce_usecs/2 and the maximum to
> > priv->tx_coalesce_usecs. Am I missing something subtle here, or did
> > you just misread my original intention from the botched code?
> 
> Yes, I missed that. Simple fix for this is:
> 
>   unsigned long t_ns = priv->tx_coalesce_usecs * NSEC_PER_USEC / 2;
>   
>   hrtimer_start_range_ns(&priv->tx_coalesce_timer, ns_to_ktime(t_ns),
>                          t_ns, HRTIMER_MODE_REL);

Ah, good. I have to admit that I'd probably make the same mistake
again if I was to do this for another driver and you hadn't sent
the fix. The hrtimer_set_expires_range() function just looked like
it had been designed for the use case I was interested in ;-).

Any idea how to prevent the next person from making the same mistake?

	Arnd
