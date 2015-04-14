From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/5] net: hip04: Make tx coalesce timer actually work
Date: Tue, 14 Apr 2015 14:15:29 -0400 (EDT)
Message-ID: <20150414.141529.797692010779414843.davem@davemloft.net>
References: <alpine.DEB.2.11.1504132338080.3845@nanos>
	<3040901.Bp3bfgc1te@wuerfel>
	<alpine.DEB.2.11.1504140007570.3845@nanos>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, linux-kernel@vger.kernel.org, peterz@infradead.org,
	mingo@kernel.org, dingtianhong@huawei.com, zhangfei.gao@linaro.org,
	dan.carpenter@oracle.com, netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1504140007570.3845@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 14 Apr 2015 00:08:23 +0200 (CEST)

> On Tue, 14 Apr 2015, Arnd Bergmann wrote:
>> On Monday 13 April 2015 23:42:03 Thomas Gleixner wrote:
>> > > 
>> > > Question: this looks to me like it sets both the minimum and maximum
>> > > time to priv->tx_coalesce_usecs/2, when the intention was to set
>> > > the minimum to priv->tx_coalesce_usecs/2 and the maximum to
>> > > priv->tx_coalesce_usecs. Am I missing something subtle here, or did
>> > > you just misread my original intention from the botched code?
>> > 
>> > Yes, I missed that. Simple fix for this is:
>> > 
>> >   unsigned long t_ns = priv->tx_coalesce_usecs * NSEC_PER_USEC / 2;
>> >   
>> >   hrtimer_start_range_ns(&priv->tx_coalesce_timer, ns_to_ktime(t_ns),
>> >                          t_ns, HRTIMER_MODE_REL);
>> 
>> Ah, good. I have to admit that I'd probably make the same mistake
>> again if I was to do this for another driver and you hadn't sent
>> the fix. The hrtimer_set_expires_range() function just looked like
>> it had been designed for the use case I was interested in ;-).
>> 
>> Any idea how to prevent the next person from making the same mistake?
> 
> Yes. Documentation :)

Can I get a respin of this patch with the above?
